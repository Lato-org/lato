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

      get lato.operation_url(id: @operation.id)
      assert_response :success
    end

    test "show should render log timestamp with local time" do
      @operation.update!(logs: [[Time.utc(2026, 1, 2, 3, 4, 5).iso8601, "Test log"]])

      authenticate_user

      get lato.operation_url(id: @operation.id)
      assert_response :success
      assert_select "time[data-local='time'][datetime='2026-01-02T03:04:05Z']", text: "03:04:05"
    end

  end
end
