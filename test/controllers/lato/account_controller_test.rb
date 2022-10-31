require "test_helper"

module Lato
  class AccountControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = lato_users(:user)
    end

    # index
    ##

    test "index should response with redirect without session" do
      get lato.account_url
      assert_redirected_to lato.root_path
    end

    test "index should response with success with session" do
      authenticate_user

      get lato.account_url
      assert_response :success
    end

    # update_user_action
    ##

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

    # request_verify_email_action
    ##

    test "request_verify_email_action should response with redirect without session" do
      patch lato.account_request_verify_email_action_url
      assert_redirected_to lato.root_path
    end

    test "request_verify_email_action should send an email to user and update temp data on redis" do
      authenticate_user

      patch lato.account_request_verify_email_action_url
      assert_redirected_to lato.account_path

      @user.reload
      assert_not_nil @user.email_verification_code
      assert_not_nil @user.email_verification_semaphore
      assert_equal ActionMailer::Base.deliveries.count, 1
    end

    test "request_verify_email_action should response with unprocessable_entity error if user try multiple send in less than 2 minutes" do
      authenticate_user

      # first send
      patch lato.account_request_verify_email_action_url
      assert_redirected_to lato.account_path

      # second send
      patch lato.account_request_verify_email_action_url
      assert_response :unprocessable_entity
    end

    test "request_verify_email_action should response with success if user try multiple send in more than 2 minutes" do
      authenticate_user

      # first send
      patch lato.account_request_verify_email_action_url
      assert_redirected_to lato.account_path

      # NOTE: second send test not works because Timecop has no way to move time on redis

      # # second send
      # Timecop.freeze(3.minutes.from_now) do
      #   patch lato.account_request_verify_email_action_url
      #   assert_redirected_to lato.account_path
      # end
    end

    # update_password_action
    ##

    test "update_password_action should response with redirect without session" do
      patch lato.account_update_password_action_url
      assert_redirected_to lato.root_path
    end

    test "update_password_action should change user password" do
      authenticate_user

      patch lato.account_update_password_action_url, params: {
        user: {
          password: 'New password',
          password_confirmation: 'New password'
        }
      }
      assert_redirected_to lato.account_path

      @user.reload
      assert @user.authenticate('New password')
    end

    # destroy_action
    ##

    test "destroy_action should response with redirect without session" do
      delete lato.account_destroy_action_url
      assert_redirected_to lato.root_path
    end

    test "destroy_action should destroy the user" do
      authenticate_user

      delete lato.account_destroy_action_url, params: {
        user: {
          email_confirmation: @user.email
        }
      }
      assert_redirected_to lato.root_path

      assert_nil Lato::User.find_by(id: @user.id)
    end
  end
end
