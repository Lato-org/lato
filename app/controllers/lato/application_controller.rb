module Lato
  class ApplicationController < ActionController::Base
    include Lato::Sessionable

    def index
      redirect_to @session.valid? ? lato.account_path : lato.authentication_signin_path
    end
  end
end
