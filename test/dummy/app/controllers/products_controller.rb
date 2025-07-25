class ProductsController < ApplicationController
  before_action :authenticate_session
  before_action { active_sidebar(:products) }

  def index
    columns = %i[id code status product_parent_id lato_user_id custom_dynamic_column created_at actions]
    sortable_columns = %i[id code status lato_user_id]
    searchable_columns = %i[id code lato_user_id]

    @products = lato_index_collection(
      Product.all.includes(:lato_user),
      columns: columns,
      sortable_columns: sortable_columns,
      searchable_columns: searchable_columns,
      # default_sort_by: 'code|ASC',
      pagination: 10,
    )

    # BACKUP: Uncomment if you want to test multiple collections on same page
    # @lato_users = lato_index_collection(
    #   Lato::User.all,
    #   columns: %i[last_name first_name email],
    #   sortable_columns: %i[last_name first_name email],
    #   searchable_columns: %i[last_name first_name email],
    #   default_sort_by: 'last_name|ASC',
    #   pagination: 10,
    #   key: 'lato_users',
    # )
  end

  def index_autocomplete
    unless params[:value].blank?
      @product = Product.find_by(id: params[:value])
      return render json: @product ? { label: @product.code, value: @product.id } : nil
    end

    @products = Product.where('code LIKE ?', "#{params[:q]}%").limit(10)
    render json: @products.map { |product| { label: product.code, value: product.id } }
  end

  def create
    @product = Product.new
  end

  def create_action
    @product = Product.new(product_params.merge(lato_user_id: @session.user_id))

    respond_to do |format|
      if @product.save
        format.html { redirect_to main_app.products_path, notice: 'Product created successfully' }
        format.json { render json: @product }
      else
        format.html { render :create, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @product = Product.find(params[:id])
  end

  def update_action
    @product = Product.find(params[:id])

    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to main_app.products_path, notice: 'Product updated successfully' }
        format.json { render json: @product }
      else
        format.html { render :update, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def export_action
    @operation = Lato::Operation.generate('ExportProductsJob', {}, @session.user_id)

    respond_to do |format|
      if @operation.start
        format.html { redirect_to lato.operation_path(@operation) }
        format.json { render json: @operation }
      else
        format.html { render :index, status: :unprocessable_entity }
        format.json { render json: @operation.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def product_params
    params.require(:product).permit(:code, :product_parent_id)
  end
end
