module Lato
  class ApplicationController < ActionController::Base
    include Lato::Sessionable
    include Lato::Layoutable
    include Lato::Componentable

    around_action :catch_exceptions

    before_action :override_request_remote_ip
    before_action :set_default_locale

    def index
      session_root_path = Lato.config.session_root_path ? main_app.send(Lato.config.session_root_path) : lato.account_path
      redirect_to @session.valid? ? session_root_path : lato.authentication_signin_path
    end

    def not_found
      respond_to_with_not_found
    end

    def error
      respond_to_with_error
    end

    def switch_locale
      I18n.locale = params[:locale]
      @session.user.update(locale: params[:locale]) if @session.valid?
      respond_to_redirect_same_page
    end

    protected

    # This method override the request remote ip with the X-Forwarded-For header if exists.
    # This method is used to get the real ip of the user when the application is behind a proxy.
    # For example if the application is behind a nginx proxy the request.remote_ip will be the ip of the proxy and not the ip of the user.
    def override_request_remote_ip
      request.remote_ip = request.headers['X-Forwarded-For'] if request.headers['X-Forwarded-For']
    end

    # This method set the default locale for the application.
    # The default locale is the locale of the user if exists, otherwise is the default locale of the application.
    def set_default_locale
      return unless @session.valid?

      I18n.locale = @session.user.locale || I18n.default_locale
    end

    def respond_to_redirect_same_page(notice = nil)
      respond_to do |format|
        format.html { redirect_to request.referer, notice: notice }
        format.json { render json: {} }
      end
    end

    def respond_to_with_not_found
      hide_sidebar
      respond_to do |format|
        format.html { render 'lato/errors/not_found', status: :not_found }
        format.json { render json: {}, status: :not_found }
      end
    end

    def respond_to_with_error(exception = nil)
      @exception = Rails.env.production? ? nil : exception

      hide_sidebar
      respond_to do |format|
        format.html { render 'lato/errors/error', status: :internal_server_error }
        format.json { render json: { error: @exception&.message || 'Internal server error' }, status: :internal_server_error }
      end
    end

    def catch_exceptions
      yield
    rescue => exception
      Rails.logger.error(exception.message)
      Rails.logger.error(exception.backtrace.join("\n"))

      if exception.is_a?(ActiveRecord::RecordNotFound)
        respond_to_with_not_found
      else
        respond_to_with_error(exception)
      end
    end
  end
end
