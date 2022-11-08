class ProductsController < ApplicationController
  before_action :authenticate_session
  before_action { active_sidebar(:products) }

  def index
    columns = %i[code status created_at]
    sortable_columns = %i[code status]

    @products = lato_index_collection(Product.all,
      columns: columns,
      sortable_columns: sortable_columns,
      pagination: true
    )
  end
end
