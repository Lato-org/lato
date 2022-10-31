module Lato
  class ApplicationController < ActionController::Base
    include Lato::Sessionable
    include Lato::Layoutable

    def index
      session_root_path = Lato.config.session_root_path ? main_app.send(Lato.config.session_root_path) : lato.account_path
      redirect_to @session.valid? ? session_root_path : lato.authentication_signin_path
    end

    protected

    def respond_to_with_404
      respond_to do |format|
        format.html { render plain: '', status: :not_found }
        format.json { render json: {}, status: :not_found }
      end
    end
  end
end
