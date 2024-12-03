require "test_helper"

module Lato
  class OperationsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = setup_lato_user
      @operation = setup_lato_operation(@user.id)
    end

    # show
    ##

    test "show should response with redirect without session" do
      get lato.operation_url(id: @operation.id)
      assert_redirected_to lato.root_path
    end

    test "show should response with success with session" do
      authenticate_user

      get lato.account_url(id: @operation.id)
      assert_response :success
    end

  end
end