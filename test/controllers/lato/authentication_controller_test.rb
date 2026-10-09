require "test_helper"

module Lato
  class AuthenticationControllerTest < ActionDispatch::IntegrationTest
    setup do
      # Rate limits and email semaphores live in cache: reset them to keep tests independent.
      Rails.cache.clear
      @user = setup_lato_user
    end

    # signin
    ##

    test "signin should response with redirect with session" do
      authenticate_user

      get lato.authentication_signin_url
      assert_redirected_to lato.root_path
    end

    test "signin should response with success" do
      get lato.authentication_signin_url
      assert_response :success
    end

    test "signin action should not log in a user without required params" do
      post lato.authentication_signin_action_url, params: { user: {
        name: 'Pippo'
      } }
      assert_response :unprocessable_entity
    end

    # signin_action
    ##

    test "signin_action should not log in a user without valid params" do
      post lato.authentication_signin_action_url, params: { user: {
        email: 'invalid_mail@mail.com',
        password: 'Password1!'
      } }
      assert_response :unprocessable_entity
    end

    test "signin_action should log in a user" do
      post lato.authentication_signin_action_url, params: { user: {
        email: @user.email,
        password: 'Password1!'
      } }
      assert_redirected_to lato.root_path

      assert_lato_session_cookie
    end

    test "signin_action should response with the same error for unknown email and wrong password" do
      bodies = [['not.registered@mail.com', 'Password1!'], [@user.email, 'WrongPassword1!']].map do |email, password|
        post lato.authentication_signin_action_url(format: :json), params: { user: { email: email, password: password } }
        assert_response :unprocessable_entity
        response.body
      end
      assert_equal bodies.first, bodies.last
    end

    test "signin_action should not expose user secrets in json response when second factor is pending" do
      Lato.config.authenticator_connection = true
      @user.generate_authenticator_secret

      post lato.authentication_signin_action_url(format: :json), params: { user: { email: @user.email, password: 'Password1!' } }
      assert_response :success
      assert_equal({ 'redirect' => lato.authentication_authenticator_path }, JSON.parse(response.body))
    ensure
      Lato.config.authenticator_connection = false
    end

    test "signin_action should set an httponly session cookie" do
      post lato.authentication_signin_action_url, params: { user: { email: @user.email, password: 'Password1!' } }
      assert_match(/lato_session=[^\n]*httponly/i, Array(response.headers['Set-Cookie']).join("\n"))
    end

    # signup
    ##

    test "signup should response with redirect with session" do
      authenticate_user

      get lato.authentication_signup_url
      assert_redirected_to lato.root_path
    end

    test "signup should response with success" do
      get lato.authentication_signup_url
      assert_response :success
    end

    # signup_action
    ##

    test "signup_action should not create a new user without required params" do
      post lato.authentication_signup_action_url, params: { user: {
        name: 'Pippo'
      } }
      assert_response :unprocessable_entity
    end

    test "signup_action should create a new user" do
      post lato.authentication_signup_action_url, params: { user: {
        first_name: 'Gino',
        last_name: 'Franco',
        email: 'gino.franco@mail.com',
        password: 'Password1!',
        password_confirmation: 'Password1!',
        accepted_privacy_policy_version: true,
        accepted_terms_and_conditions_version: true
      }}
      assert_redirected_to lato.root_path

      assert_lato_session_cookie
    end

    # signout
    ##

    test "signout should response with redirect without session" do
      get lato.authentication_signout_url
      assert_redirected_to lato.root_path
    end

    test "signout should response with success with session" do
      authenticate_user

      get lato.authentication_signout_url
      assert_response :success
    end

    # signout_action
    ##

    test "signout_action should response with redirect without session" do
      delete lato.authentication_signout_action_url
      assert_redirected_to lato.root_path
    end

    test "signout_action should destroy user session" do
      authenticate_user

      delete lato.authentication_signout_action_url
      assert_redirected_to lato.root_path

      assert_not_lato_session_cookie
    end

    # verify_email
    ##

    test "verify_email should response with not_found error if user not exists" do
      get lato.authentication_verify_email_url(id: 9999999)
      assert_response :not_found
    end

    test "verify_email should response with success" do
      get lato.authentication_verify_email_url(id: @user.id)
      assert_response :success
    end

    # verify_email_action
    ##

    test "verify_email_action should response with not_found error if user not exists" do
      patch lato.authentication_verify_email_action_url(id: 9999999)
      assert_response :not_found
    end

    test "verify_email_action should response with unprocessable_entity error if code is not valid" do
      @user.c_email_verification_code('')

      patch lato.authentication_verify_email_action_url(id: @user.id), params: {
        user: {
          code: 'invalid_code'
        }
      }
      assert_response :unprocessable_entity
    end

    test "verify_email_action should update email_verified_at" do
      @user.update_columns(email_verified_at: nil)
      @user.c_email_verification_code('valid_code')

      patch lato.authentication_verify_email_action_url(id: @user.id), params: {
        user: {
          code: 'valid_code'
        }
      }
      assert_redirected_to lato.root_path

      @user.reload
      assert_not_nil @user.email_verified_at
    end

    # recover_password
    ##

    test "recover_password should response with success" do
      get lato.authentication_recover_password_url
      assert_response :success
    end

    # recover_password_action
    ##

    test "recover_password_action should response with unprocessable_entity error if email is blank" do
      post lato.authentication_recover_password_action_url, params: { user: { email: '' } }
      assert_response :unprocessable_entity
    end

    test "recover_password_action should response like a registered email if email not exists" do
      assert_no_enqueued_emails do
        post lato.authentication_recover_password_action_url, params: { user: { email: 'not.registered@mail.com' } }
      end
      assert_redirected_to lato.authentication_update_password_path
    end

    test "recover_password_action should generate an password_update_code and send it via email to user" do
      assert_enqueued_emails 1 do
        post lato.authentication_recover_password_action_url, params: { user: { email: @user.email } }
      end
      assert_redirected_to lato.authentication_update_password_path
      assert_not_nil @user.c_password_update_code
    end

    test "recover_password_action should send at most one email per user every 2 minutes" do
      assert_enqueued_emails 1 do
        2.times { post lato.authentication_recover_password_action_url, params: { user: { email: @user.email } } }
      end
    end

    test "recover_password_action should not expose user data in json response" do
      post lato.authentication_recover_password_action_url(format: :json), params: { user: { email: @user.email } }
      assert_response :success
      assert_equal({}, JSON.parse(response.body))
    end

    # Behind a reverse proxy the client controls the leftmost X-Forwarded-For values, the proxy appends the real IP.
    test "recover_password_action should not let X-Forwarded-For bypass the requests limit" do
      statuses = 12.times.map do |i|
        post lato.authentication_recover_password_action_url, params: { user: { email: "user#{i}@mail.com" } }, headers: { 'X-Forwarded-For' => "203.0.113.#{i}, 198.51.100.1" }
        response.status
      end
      assert_includes statuses, 429
    end

    # update_password
    ##

    test "update_password should redirect to recover_password without a recover request" do
      get lato.authentication_update_password_url
      assert_redirected_to lato.authentication_recover_password_path
    end

    test "update_password should response with success" do
      request_recover_password(@user.email)
      get lato.authentication_update_password_url
      assert_response :success
    end

    # update_password_action
    ##

    test "update_password_action should redirect to recover_password without a recover request" do
      patch lato.authentication_update_password_action_url
      assert_redirected_to lato.authentication_recover_password_path
    end

    test "update_password_action should response with unprocessable_entity error if code is not valid" do
      request_recover_password(@user.email)

      patch lato.authentication_update_password_action_url, params: { user: { code: 'invalid_code' } }
      assert_response :unprocessable_entity
    end

    test "update_password_action should response with the same error for registered and not registered emails" do
      bodies = [@user.email, 'not.registered@mail.com'].map do |email|
        request_recover_password(email)
        patch lato.authentication_update_password_action_url(format: :json), params: { user: { code: 'invalid_code' } }
        assert_response :unprocessable_entity
        response.body
      end
      assert_equal bodies.first, bodies.last
    end

    test "update_password pages should render the same html for registered and not registered emails" do
      pages = [@user.email, 'not.registered@mail.com'].map do |email|
        request_recover_password(email)
        get lato.authentication_update_password_url
        form = without_csrf_tokens(response.body)
        patch lato.authentication_update_password_action_url, params: { user: { code: 'invalid_code' } }
        [form, without_csrf_tokens(response.body)]
      end
      assert_equal pages.first, pages.last
    end

    test "update_password_action should update user password" do
      request_recover_password(@user.email)
      @user.c_password_update_code('valid_code')

      patch lato.authentication_update_password_action_url, params: {
        user: {
          code: 'valid_code',
          password: 'New password',
          password_confirmation: 'New password'
        }
      }
      assert_redirected_to lato.authentication_signin_path

      @user.reload
      assert @user.authenticate('New password')
    end

    # accept_invitation
    ##

    test "accept_invitation should response with not_found error if user not exists" do
      get lato.authentication_accept_invitation_url(id: 9999999)
      assert_response :not_found
    end

    test "accept_invitation should response with success" do
      invitation = setup_lato_invitation

      get lato.authentication_accept_invitation_url(id: invitation.id, accepted_code: invitation.accepted_code)
      assert_response :success
    end

    # accept_invitation_action
    ##

    test "accept_invitation_action should not create a new user without required params" do
      invitation = setup_lato_invitation

      post lato.authentication_accept_invitation_action_url(id: invitation.id, accepted_code: invitation.accepted_code), params: {
        user: {
          email: ''
        }
      }
      assert_response :unprocessable_entity
    end

    test "accept_invitation_action should create a new user" do
      invitation = setup_lato_invitation

      post lato.authentication_accept_invitation_action_url(id: invitation.id, accepted_code: invitation.accepted_code), params: {
        user: {
          first_name: 'Gino',
          last_name: 'Franco',
          email: invitation.email,
          password: 'Password1!',
          password_confirmation: 'Password1!',
          accepted_privacy_policy_version: true,
          accepted_terms_and_conditions_version: true
        }
      }
      assert_redirected_to lato.root_path

      assert_lato_session_cookie
    end

    # authenticator
    ##

    test "authenticator should response with not_found error if user not exists" do
      get lato.authentication_authenticator_url
      assert_response :not_found
    end

    private

    def request_recover_password(email)
      post lato.authentication_recover_password_action_url, params: { user: { email: email } }
    end

    def without_csrf_tokens(html)
      html.gsub(/(name="authenticity_token" value|name="csrf-token" content)="[^"]*"/, '\1=""')
    end

    def assert_lato_session_cookie
      jar = ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
      assert_not_nil jar.encrypted[:lato_session]
    end

    def assert_not_lato_session_cookie
      jar = ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
      assert_nil jar.encrypted[:lato_session]
    end
  end
end
