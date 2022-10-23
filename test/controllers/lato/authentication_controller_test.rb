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
    end
  end
end