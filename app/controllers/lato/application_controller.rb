module Lato
  class ApplicationController < ActionController::Base
    def index
      redirect_to lato.authentication_signin_path
    end
  end
end
