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

  test "sort buttons have accessible names and active column exposes aria-sort" do
    get "/products", params: { default_sort_by: "code|ASC" }

    assert_response :success
    assert_select "button[name$=\"_sort_by\"][aria-label]"
    assert_select "th[aria-sort=ascending]", count: 1
  end

  test "search form does not reflect routing params as hidden fields" do
    get "/products"

    assert_select "form input[type=hidden][name=controller]", count: 0
    assert_select "form input[type=hidden][name=action]", count: 0
  end
end
