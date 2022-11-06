class DashboardController < ApplicationController
  before_action :authenticate_session
  before_action { active_sidebar(:dashboard) }

  def index
    active_sidebar(:dashboard)
  end

  def configuration
    active_sidebar(:configuration)
  end

  def customization
    active_sidebar(:customization)
  end

  def components
    active_sidebar(:components)
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
