module Lato
  class AccountController < ApplicationController
    before_action :authenticate_session
    before_action { active_navbar(:account) }

    def index; end

    def update_user_action
      respond_to do |format|
        if @session.user.update(params.require(:user).permit(:first_name, :last_name, :email))
          format.html { redirect_to lato.account_path, notice: 'Informazioni account aggiornate correttamente' }
          format.json { render json: @session.user }
        else
          format.html { render :index, status: :unprocessable_entity }
          format.json { render json: @session.user.errors, status: :unprocessable_entity }
        end
      end
    end
  end
end
