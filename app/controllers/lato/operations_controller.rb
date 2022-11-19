module Lato
  class OperationsController < ApplicationController
    before_action :authenticate_session

    def show
      @operation = Lato::Operation.find(params[:id])
      return unless validate_user_access_to_operation
    end

    private

    def validate_user_access_to_operation
      return true if @operation.lato_user_id == @session.user_id

      respond_to do |format|
        format.html { redirect_to lato.root_path }
        format.json { render plain: '', status: :unauthorized }
      end

      false
    end
  end
end
