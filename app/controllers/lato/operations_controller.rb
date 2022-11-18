module Lato
  class OperationsController < ApplicationController
    before_action :authenticate_session

    def show
      @operation = Lato::Operation.find(params[:id])
    end
  end
end
