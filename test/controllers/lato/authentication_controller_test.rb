require "test_helper"

module Lato
  class AuthenticationControllerTest < ActionDispatch::IntegrationTest
    setup do
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

    test "recover_password_action should response with unprocessable_entity error if email not exists" do
      post lato.authentication_recover_password_action_url, params: {
        user: {
          email: 'cocaina'
        }
      }
      assert_response :unprocessable_entity
    end

    test "recover_password_action should generate an password_update_code and send it via email to user" do
      @user.c_password_update_code('')

      post lato.authentication_recover_password_action_url, params: {
        user: {
          email: @user.email
        }
      }
      assert_redirected_to lato.authentication_update_password_url(id: @user.id)

      @user.reload
      assert_not_nil @user.c_password_update_code
      assert_equal ActionMailer::Base.deliveries.count, 1
    end

    # update_password
    ##

    test "update_password should response with not_found error if user not exists" do
      get lato.authentication_update_password_url(id: 9999999)
      assert_response :not_found
    end

    test "update_password should response with success" do
      get lato.authentication_update_password_url(id: @user.id)
      assert_response :success
    end

    # update_password_action
    ##

    test "update_password_action should response with not_found error if user not exists" do
      patch lato.authentication_update_password_action_url(id: 9999999)
      assert_response :not_found
    end

    test "update_password_action should response with unprocessable_entity error if code is not valid" do
      @user.c_password_update_code('')

      patch lato.authentication_update_password_action_url(id: @user.id), params: {
        user: {
          code: 'invalid_code'
        }
      }
      assert_response :unprocessable_entity
    end

    test "update_password_action should update user password" do
      @user.c_password_update_code('valid_code')

      patch lato.authentication_update_password_action_url(id: @user.id), params: {
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
