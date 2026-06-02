require "test_helper"

class LatoIndexSecurityTest < ActionDispatch::IntegrationTest
  setup do
    @user = setup_lato_user
    Product.create!(code: "A", status: :created, lato_user: @user)
    authenticate_user
  end

  test "ignores unsafe sort column" do
    get "/products", params: { default_sort_by: "id) DESC; SELECT 1--|asc" }

    assert_response :success
  end

  test "ignores unsafe sort direction" do
    get "/products", params: { default_sort_by: "id|desc; SELECT 1--" }

    assert_response :success
  end
end
