require "test_helper"

module Lato
  class AuthenticationControllerTest < ActionDispatch::IntegrationTest
    test "signin should response with success" do
      get lato.authentication_signin_url
      assert_response :success
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

    test "signup action should create a new user with required params" do
      post lato.authentication_signup_action_url, params: { user: {
        first_name: 'Gregorio',
        last_name: 'Galante',
        email: 'me@gregoriogalante.com',
        password: 'Password1!',
        password_confirmation: 'Password1!'
      }}
      assert_redirected_to lato.root_path
    end
  end
end