require "test_helper"
require "webauthn/fake_client"

module Lato
  class SecurityRegressionTest < ActionDispatch::IntegrationTest
    setup do
      Rails.cache.clear
      @user = setup_lato_user
      @authenticator_connection = Lato.config.authenticator_connection
      Lato.config.authenticator_connection = false
    end

    teardown do
      Lato.config.authenticator_connection = @authenticator_connection
    end

    test "legacy and malformed session payloads cannot authenticate" do
      [nil, "[]", "{", { user_id: @user.id }, { user_id: @user.id, token: "unknown" }].each do |payload|
        assert_not Lato::Session.new(payload).really_valid?
      end
    end

    test "session tokens survive payload changes but logout revokes only current device" do
      first = Lato::Session.new(Lato::Session.generate_session_per_user(@user.id))
      second = Lato::Session.new(Lato::Session.generate_session_per_user(@user.id, spaces_group_id: 42))
      updated = Lato::Session.new(first.update(spaces_group_id: 13, user_id: 0, token: "replacement"))
      assert_equal 13, updated.get(:spaces_group_id)
      assert_equal @user.id, updated.user_id
      first.destroy
      assert_not updated.really_valid?
      assert second.really_valid?
    end

    test "expired sessions and sessions of deleted users are invalid" do
      payload = Lato::Session.generate_session_per_user(@user.id)
      @user.lato_session_records.update_all(expires_at: 1.second.ago)
      assert_not Lato::Session.new(payload).really_valid?
      payload = Lato::Session.generate_session_per_user(@user.id)
      @user.destroy!
      assert_not Lato::Session.new(payload).really_valid?
    end

    test "replaying cookie after logout fails" do
      authenticate_user
      stolen_cookie = cookies[:lato_session]
      delete lato.authentication_signout_action_url
      cookies[:lato_session] = stolen_cookie
      get lato.account_url(format: :json)
      assert_response :unauthorized
    end

    test "changing password invalidates all devices and requires current password" do
      authenticate_user
      first_cookie = cookies[:lato_session]
      other = Lato::Session.new(Lato::Session.generate_session_per_user(@user.id))
      patch lato.account_update_password_action_url(format: :json), params: { user: { password: "NewPassword1!", password_confirmation: "NewPassword1!" } }
      assert_response :unprocessable_entity
      assert @user.reload.authenticate("Password1!")
      patch lato.account_update_password_action_url(format: :json), params: { user: { current_password: "Password1!", password: "NewPassword1!", password_confirmation: "NewPassword1!" } }
      assert_response :success
      assert_not other.really_valid?
      cookies[:lato_session] = first_cookie
      get lato.account_url(format: :json)
      assert_response :unauthorized
    end

    test "password recovery invalidates every existing session" do
      old = Lato::Session.new(Lato::Session.generate_session_per_user(@user.id))
      @user.c_password_update_code("RECOVERY")
      assert @user.update_password(ActionController::Parameters.new(code: "RECOVERY", password: "NewPassword1!", password_confirmation: "NewPassword1!"))
      assert_not old.really_valid?
    end

    test "password recovery preserves second factors" do
      @user.generate_authenticator_secret
      secret = @user.authenticator_secret
      @user.c_password_update_code("RECOVERY")
      assert @user.update_password(ActionController::Parameters.new(code: "RECOVERY", password: "NewPassword1!", password_confirmation: "NewPassword1!"))
      assert_equal secret, @user.reload.authenticator_secret
    end
    
    test "security grants are single use scoped to device and action and expire" do
      first = Lato::Session.new(Lato::Session.generate_session_per_user(@user.id))
      second = Lato::Session.new(Lato::Session.generate_session_per_user(@user.id))
      first.grant_security_continuation("enroll")
      assert_not first.consume_security_continuation("other_action")
      assert_not second.consume_security_continuation("enroll")
      assert first.consume_security_continuation("enroll")
      assert_not first.consume_security_continuation("enroll")
      first.grant_security_continuation("enroll")
      travel 6.minutes do
        assert_not first.consume_security_continuation("enroll")
      end
    end
    
    test "security key challenges are single use and expire" do
      current = Lato::Session.new(Lato::Session.generate_session_per_user(@user.id))
      current.set_security_challenge("challenge")
      assert_equal "challenge", current.take_security_challenge
      assert_nil current.take_security_challenge
      current.set_security_challenge("challenge")
      travel 6.minutes do
        assert_nil current.take_security_challenge
      end
    end

    test "failed password update keeps sessions valid" do
      old = Lato::Session.new(Lato::Session.generate_session_per_user(@user.id))
      assert_not @user.update(password: "NewPassword1!", password_confirmation: "different")
      assert old.really_valid?
    end

    test "email change requires current password" do
      authenticate_user
      patch lato.account_update_user_action_url(format: :json), params: { user: { email: "new@mail.com" } }
      assert_response :unprocessable_entity
      assert_equal "pippo.franco@mail.com", @user.reload.email
    end

    test "verification code cannot verify a changed address or be restored by changing back" do
      @user.c_email_verification_code("OLD")
      old_email = @user.email
      @user.update!(email: "new@mail.com")
      assert_not @user.verify_email(code: "OLD")
      @user.update!(email: old_email)
      assert_not @user.verify_email(code: "OLD")
      assert_nil @user.reload.email_verified_at
    end

    test "stale user cannot verify concurrently changed email" do
      @user.c_email_verification_code("OLD")
      Lato::User.where(id: @user.id).update_all(email: "new@mail.com", email_verified_at: nil)
      assert_not @user.verify_email(code: "OLD")
      assert_nil @user.reload.email_verified_at
    end

    test "password confirmation does not bypass enrolled second factor" do
      authenticate_user
      @user.generate_authenticator_secret
      patch lato.account_update_password_action_url(format: :json), params: { user: { current_password: "Password1!", password: "NewPassword1!", password_confirmation: "NewPassword1!" } }
      assert_response :unprocessable_entity
      assert @user.reload.authenticate("Password1!")
    end

    test "authenticator enrollment stays pending until valid OTP and secret stays hidden afterwards" do
      authenticate_user
      Lato.config.authenticator_connection = true
      patch lato.account_update_authenticator_action_url(format: :json), params: { user: { current_password: "Password1!" } }
      assert_response :success
      secret = JSON.parse(response.body).fetch("secret")
      assert_nil @user.reload.authenticator_secret
      patch lato.account_update_authenticator_action_url(format: :json), params: { user: { authenticator_command: "confirm", authenticator_code: ROTP::TOTP.new(secret).now } }
      assert_response :success
      assert_equal secret, @user.reload.authenticator_secret
      get lato.account_url
      assert_response :success
      assert_select "turbo-frame#account_form-authenticator img", count: 0
      patch lato.account_update_authenticator_action_url(format: :json), params: { user: { current_password: "Password1!" } }
      assert_response :unprocessable_entity
      assert_equal secret, @user.reload.authenticator_secret
      patch lato.account_update_authenticator_action_url(format: :json), params: { user: { current_password: "Password1!", current_authenticator_code: ROTP::TOTP.new(secret).now } }
      assert_response :success
      assert_nil @user.reload.authenticator_secret
    end

    test "security key account changes require a fresh valid assertion and password" do
      authenticate_user
      original_origins = WebAuthn.configuration.allowed_origins
      WebAuthn.configuration.allowed_origins = ["http://www.example.com"]
      client = WebAuthn::FakeClient.new("http://www.example.com")
      options = @user.webauthn_registration_options
      credential = client.create(challenge: options.challenge)
      assert @user.register_webauthn_credential(credential.to_json, Base64.strict_encode64(options.challenge))
    
      patch lato.account_update_user_action_url(format: :json), params: { user: { email: "updated@mail.com", current_password: "Password1!" } }
      assert_response :unprocessable_entity
      post lato.account_security_challenge_url(format: :json)
      assert_response :success
      options = JSON.parse(response.body)
      credential = client.get(challenge: options.fetch("challenge"))
      patch lato.account_update_user_action_url(format: :json), params: { user: { email: "updated@mail.com", current_password: "Password1!", current_webauthn_credential: credential.to_json } }
      assert_response :success
      assert_equal "updated@mail.com", @user.reload.email
      patch lato.account_update_user_action_url(format: :json), params: { user: { email: "replay@mail.com", current_password: "Password1!", current_webauthn_credential: credential.to_json } }
      assert_response :unprocessable_entity
      assert_equal "updated@mail.com", @user.reload.email
    ensure
      WebAuthn.configuration.allowed_origins = original_origins
    end

    test "expired enrollment returns to password confirmation" do
      authenticate_user
      Lato.config.authenticator_connection = true
      patch lato.account_update_authenticator_action_url(format: :json), params: { user: { current_password: "Password1!" } }
      assert_response :success
      travel 6.minutes do
        get lato.account_url
        assert_response :success
        assert_select "turbo-frame#account_form-authenticator img", count: 0
        assert_select "turbo-frame#account_form-authenticator input[name='user[current_password]']", count: 1
      end
    end

    test "invalid OTP does not enroll pending authenticator" do
      authenticate_user
      Lato.config.authenticator_connection = true
      patch lato.account_update_authenticator_action_url(format: :json), params: { user: { current_password: "Password1!" } }
      patch lato.account_update_authenticator_action_url(format: :json), params: { user: { authenticator_command: "confirm", authenticator_code: "invalid" } }
      assert_response :unprocessable_entity
      assert_nil @user.reload.authenticator_secret
    end
  end
end
