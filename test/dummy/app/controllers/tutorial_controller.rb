class TutorialController < ApplicationController
  before_action :authenticate_session
  before_action { active_sidebar(:tutorial) }

  def index
    active_sidebar(:tutorial)
  end

  # Configuration
  ##

  def configuration
    active_sidebar(:configuration)
  end

  # Customization
  ##

  def customization
    active_sidebar(:customization)
  end

  # Components
  ##

  def components
    active_sidebar(:components)

    @products = lato_index_collection(
      Product.all,
      pagination: true,
      key: 'products'
    )
    @products_pagination_options = lato_index_collection(
      Product.all,
      pagination: 10,
      columns: %i[code status id],
      key: 'products_pagination_options'
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

  def components_update_user_action
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

  # Operations
  ##

  def operations
    active_sidebar(:operations)
  end

  def operations_create_operation_action
    @operation = Lato::Operation.generate('OperationExampleJob', params.permit(:type), @session.user_id, params[:file])

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

  # Actions
  ##

  def actions
    active_sidebar(:actions)
  end

  # Invitations
  ##

  def invitations
    active_sidebar(:invitations)

    @invitations = lato_index_collection(
      Lato::Invitation.all,
    )
  end

  def invitations_create_invite_action
    @invitation = Lato::Invitation.new(params.require(:invitation).permit(:email).merge(inviter_lato_user_id: @session.user_id))

    respond_to do |format|
      if @invitation.save
        format.html { redirect_to main_app.invitations_path, notice: 'Invito creato correttamente' }
        format.json { render json: @invitation }
      else
        format.html { redirect_to main_app.invitations_path, alert: @invitation.errors.full_messages.join(', ') }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  def invitations_send_invite_action
    @invitation = Lato::Invitation.find(params[:id])

    respond_to do |format|
      if @invitation.send_invite
        format.html { redirect_to main_app.invitations_path, notice: 'Invito inviato correttamente' }
        format.json { render json: @invitation }
      else
        format.html { redirect_to main_app.invitations_path, alert: @invitation.errors.full_messages.join(', ') }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  def invitations_destroy_invite_action
    @invitation = Lato::Invitation.find(params[:id])

    respond_to do |format|
      if @invitation.destroy
        format.html { redirect_to main_app.invitations_path, notice: 'Invito eliminato correttamente' }
        format.json { render json: @invitation }
      else
        format.html { redirect_to main_app.invitations_path, alert: 'Invito non eliminato' }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # Guide
  
  def guide
    active_sidebar(:guide)
  end

end
