module Lato
  class ApplicationController < ActionController::Base
    include Lato::Sessionable
    include Lato::Layoutable
    include Lato::Componentable

    before_action :set_default_locale

    def index
      session_root_path = Lato.config.session_root_path ? main_app.send(Lato.config.session_root_path) : lato.account_path
      redirect_to @session.valid? ? session_root_path : lato.authentication_signin_path
    end

    def switch_locale
      I18n.locale = params[:locale]
      @session.user.update(locale: params[:locale]) if @session.valid?
      respond_to_redirect_same_page
    end

    protected

    def set_default_locale
      return unless @session.valid?

      I18n.locale = @session.user.locale || I18n.default_locale
    end

    def respond_to_with_not_found
      respond_to do |format|
        format.html { render plain: '', status: :not_found }
        format.json { render json: {}, status: :not_found }
      end
    end

    def respond_to_redirect_same_page(notice = nil)
      respond_to do |format|
        format.html { redirect_to request.referer, notice: notice }
        format.json { render json: {} }
      end
    end
  end
end
