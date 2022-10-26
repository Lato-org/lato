require "test_helper"

module Lato
  class AuthenticationControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = lato_users(:user)
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

    test "signin action should not log in a user without valid params" do
      post lato.authentication_signin_action_url, params: { user: {
        email: 'invalid_mail@mail.com',
        password: 'Password1!'
      } }
      assert_response :unprocessable_entity
    end

    test "signin action should log in a user" do
      post lato.authentication_signin_action_url, params: { user: {
        email: @user.email,
        password: 'Password1!'
      } }
      assert_redirected_to lato.root_path

      assert_lato_session_cookie
    end

    test "signup should response with success" do
      get lato.authentication_signup_url
      assert_response :success
    end

    test "signup action should not create a new user without required params" do
      post lato.authentication_signup_action_url, params: { user: {
        name: 'Pippo'
      } }
      assert_response :unprocessable_entity
    end

    test "signup action should create a new user" do
      post lato.authentication_signup_action_url, params: { user: {
        first_name: 'Gino',
        last_name: 'Franco',
        email: 'gino.franco@mail.com',
        password: 'Password1!',
        password_confirmation: 'Password1!'
      }}
      assert_redirected_to lato.root_path

      assert_lato_session_cookie
    end

    test "signout should response with redirect without session" do
      get lato.authentication_signout_url
      assert_redirected_to lato.root_path
    end

    test "signout should response with success with session" do
      authenticate_user

      get lato.authentication_signout_url
      assert_response :success
    end

    test "signout action should destroy user session" do
      authenticate_user

      delete lato.authentication_signout_action_url
      assert_redirected_to lato.root_path

      assert_not_lato_session_cookie
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