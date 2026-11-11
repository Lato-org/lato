require "test_helper"
require "webauthn/fake_client"

module Lato
  class SecurityConfigTest < ActionDispatch::IntegrationTest
    CONFIG_KEYS = %i[invitation_lifetime session_idle_timeout webauthn_user_verification].freeze

    setup do
      Rails.cache.clear
      @user = setup_lato_user
      @config = CONFIG_KEYS.index_with { |key| Lato.config.public_send(key) }
    end

    teardown do
      @config.each { |key, value| Lato.config.public_send("#{key}=", value) }
    end

    # Invitation lifetime
    ##

    test "invitations expire after the configured lifetime" do
      invitation = setup_lato_invitation
      assert_not invitation.expired?

      travel 31.days do
        assert invitation.expired?

        Lato.config.invitation_lifetime = nil
        assert_not invitation.expired?
      end
    end

    test "resending an invitation restarts its lifetime" do
      invitation = setup_lato_invitation

      travel 29.days do
        Rails.cache.clear
        assert invitation.send_invite
      end

      travel 31.days do
        assert_not invitation.reload.expired?
      end
    end

    test "expired invitations show an error and can not be accepted" do
      invitation = setup_lato_invitation

      travel 31.days do
        get lato.authentication_accept_invitation_url(id: invitation.id, accepted_code: invitation.accepted_code)
        assert_response :success
        assert_includes response.body, I18n.t("activerecord.errors.models.lato/user.attributes.base.invitation_expired")

        post lato.authentication_accept_invitation_action_url(id: invitation.id, accepted_code: invitation.accepted_code), params: { user: invitation_registration_params(invitation) }
        assert_response :unprocessable_entity
        assert_includes response.body, I18n.t("activerecord.errors.models.lato/user.attributes.base.invitation_expired")
      end

      assert_not invitation.reload.accepted?
      assert_nil Lato::User.find_by(email: invitation.email)
    end

    test "invitation expired error is translated in every locale" do
      # The dummy app enables only some locales, so read the engine locale files directly.
      %w[it en fr ro].each do |locale|
        translations = YAML.load_file(Lato::Engine.root.join("config/locales/#{locale}.yml"))
        assert translations.dig(locale, "activerecord", "errors", "models", "lato/user", "attributes", "base", "invitation_expired").present?, "missing #{locale} translation"
      end
    end

    # Session idle timeout
    ##

    test "idle sessions are revoked when idle timeout is set" do
      Lato.config.session_idle_timeout = 1.hour
      authenticate_user

      travel 59.minutes do
        get lato.account_url
        assert_response :success
      end

      travel 2.hours do
        get lato.account_url
        assert_redirected_to lato.root_path
      end

      assert_empty @user.lato_session_records.reload
    end

    test "session activity is written at most once per minute" do
      Lato.config.session_idle_timeout = 1.hour
      authenticate_user
      record = @user.lato_session_records.last

      travel 30.seconds do
        get lato.account_url
      end
      assert_equal record.updated_at, record.reload.updated_at

      travel 2.minutes do
        get lato.account_url
        assert_in_delta Time.current, record.reload.updated_at, 1.second
      end
    end

    test "sessions are not revoked for inactivity when idle timeout is disabled" do
      Lato.config.session_idle_timeout = nil
      authenticate_user

      travel 2.days do
        get lato.account_url
        assert_response :success
      end
    end

    # WebAuthn user verification
    ##

    test "webauthn options use the configured user verification" do
      Lato.config.webauthn_user_verification = "required"

      assert_equal "required", @user.webauthn_authentication_options.user_verification
      assert_equal "required", @user.webauthn_registration_options.as_json.dig(:authenticatorSelection, :userVerification)
    end

    test "webauthn required user verification is enforced server-side" do
      with_webauthn_client do |client|
        Lato.config.webauthn_user_verification = "required"

        # A separate client: the fake client keeps every credential it creates, even the rejected one.
        unverified_client = WebAuthn::FakeClient.new("http://www.example.com")
        options = @user.webauthn_registration_options
        assert_not @user.register_webauthn_credential(unverified_client.create(challenge: options.challenge, user_verified: false).to_json, Base64.strict_encode64(options.challenge))
        options = @user.webauthn_registration_options
        assert @user.register_webauthn_credential(client.create(challenge: options.challenge, user_verified: true).to_json, Base64.strict_encode64(options.challenge))

        options = @user.webauthn_authentication_options
        assert_not @user.webauthn_authentication({ webauthn_credential: client.get(challenge: options.challenge, user_verified: false, sign_count: 1).to_json }, options.challenge)
        options = @user.webauthn_authentication_options
        assert @user.webauthn_authentication({ webauthn_credential: client.get(challenge: options.challenge, user_verified: true, sign_count: 2).to_json }, options.challenge)
      end
    end

    test "webauthn preferred user verification accepts unverified responses" do
      with_webauthn_client do |client|
        Lato.config.webauthn_user_verification = "preferred"

        options = @user.webauthn_registration_options
        assert @user.register_webauthn_credential(client.create(challenge: options.challenge).to_json, Base64.strict_encode64(options.challenge))

        options = @user.webauthn_authentication_options
        assert @user.webauthn_authentication({ webauthn_credential: client.get(challenge: options.challenge, sign_count: 1).to_json }, options.challenge)
      end
    end

    # Authenticator secret encryption (enabled for the test suite in test/dummy/config/environments/test.rb)
    ##

    test "authenticator secret is encrypted at rest when enabled" do
      assert_includes Lato::User.encrypted_attributes, :authenticator_secret

      @user.generate_authenticator_secret
      secret = @user.reload.authenticator_secret
      stored = Lato::User.connection.select_value(Lato::User.where(id: @user.id).select(:authenticator_secret).to_sql)

      assert secret.present?
      assert_not_equal secret, stored
      assert_not_includes stored, secret
    end

    private

    def invitation_registration_params(invitation)
      {
        first_name: "Gino",
        last_name: "Franco",
        email: invitation.email,
        password: "Password1!",
        password_confirmation: "Password1!",
        accepted_privacy_policy_version: true,
        accepted_terms_and_conditions_version: true
      }
    end

    def with_webauthn_client
      original_origins = WebAuthn.configuration.allowed_origins
      WebAuthn.configuration.allowed_origins = ["http://www.example.com"]
      yield WebAuthn::FakeClient.new("http://www.example.com")
    ensure
      WebAuthn.configuration.allowed_origins = original_origins
    end
  end
end
