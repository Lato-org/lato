class TutorialController < ApplicationController
  before_action :authenticate_session
  before_action { active_sidebar(:tutorial) }

  def index
    active_sidebar(:tutorial)
  end

  def configuration
    active_sidebar(:configuration)
  end

  def customization
    active_sidebar(:customization)
  end

  def components
    active_sidebar(:components)

    @products = lato_index_collection(
      Product.all,
      pagination: true,
      key: 'products'
    )
    @products_columns = lato_index_collection(
      Product.all,
      pagination: true,
      columns: %i[code status id],
      key: 'products_columns'
    )
    @products_sortable_columns = lato_index_collection(
      Product.all,
      pagination: true,
      columns: %i[code status lato_user_id],
      sortable_columns: %i[code status lato_user_id],
      key: 'products_sortable_columns'
    )
    @products_searchable_columns = lato_index_collection(
      Product.all,
      pagination: true,
      columns: %i[code status lato_user_id],
      sortable_columns: %i[code status lato_user_id],
      searchable_columns: %i[code lato_user_id],
      key: 'products_searchable_columns'
    )
  end

  def operations
    active_sidebar(:operations)
  end

  def update_user_action
    respond_to do |format|
      if @session.user.update(params.require(:user).permit(:first_name, :last_name))
        format.html { redirect_to main_app.components_path, notice: 'Informazioni account aggiornate correttamente' }
        format.json { render json: @session.user }
      else
        format.html { render :components, status: :unprocessable_entity }
        format.json { render json: @session.user.errors, status: :unprocessable_entity }
      end
    end
  end
end
