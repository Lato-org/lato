module Lato
  class ApplicationController < ActionController::Base
    include Lato::Sessionable

    def index
      session_root_path = Lato.config.session_root_path ? main_app.send(Lato.config.session_root_path) : lato.account_path
      redirect_to @session.valid? ? session_root_path : lato.authentication_signin_path
    end
  end
end
