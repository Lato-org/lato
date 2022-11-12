class ProductsController < ApplicationController
  before_action :authenticate_session
  before_action { active_sidebar(:products) }

  def index
    columns = %i[code status lato_user_id created_at actions]
    sortable_columns = %i[code status lato_user_id]
    searchable_columns = %i[code lato_user_id]

    @products = lato_index_collection(
      Product.all.includes(:lato_user),
      columns: columns,
      sortable_columns: sortable_columns,
      searchable_columns: searchable_columns,
      pagination: true
    )
  end

  def create
    @product = Product.new
  end

  def update
    @product = Product.find(params[:id])
  end
end
