require "test_helper"

module Lato
  class AccountControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = lato_users(:user)
    end

    test "index should response with redirect without session" do
      get lato.account_url
      assert_redirected_to lato.root_path
    end

    test "index should response with success with session" do
      authenticate_user

      get lato.account_url
      assert_response :success
    end

    test "update_user_action should response with redirect without session" do
      patch lato.account_update_user_action_url
      assert_redirected_to lato.root_path
    end

    test "update_user_action should update user data" do
      authenticate_user

      new_first_name = "#{@user.first_name}_update"
      new_last_name = "#{@user.last_name}_update"
      patch lato.account_update_user_action_url, params: {
        user: {
          first_name: new_first_name,
          last_name: new_last_name
        }
      }
      assert_redirected_to lato.account_path

      @user.reload
      assert_equal @user.first_name, new_first_name
      assert_equal @user.last_name, new_last_name
    end

    test "update_user_action should reset email_verified_at if email is changed" do
      authenticate_user

      new_email = "#{@user.email}.update"
      patch lato.account_update_user_action_url, params: {
        user: {
          email: new_email
        }
      }
      assert_redirected_to lato.account_path

      @user.reload
      assert_equal @user.email, new_email
      assert_nil @user.email_verified_at
    end

    test "update_user_action should not reset email_verified_at if email is not changed" do
      authenticate_user

      old_email = @user.email
      patch lato.account_update_user_action_url, params: {
        user: {
          email: old_email
        }
      }
      assert_redirected_to lato.account_path

      @user.reload
      assert_equal @user.email, old_email
      assert_not_nil @user.email_verified_at
    end
  end
end
