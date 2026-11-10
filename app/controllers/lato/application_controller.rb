module Lato
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    include Lato::Sessionable
    include Lato::Layoutable
    include Lato::Componentable

    helper LocalTimeHelper

    around_action :catch_exceptions

    before_action :set_default_locale

    def index
      session_root_path = Lato.config.session_root_path ? main_app.send(Lato.config.session_root_path) : lato.account_path
      redirect_to @session.really_valid? ? session_root_path : lato.authentication_signin_path
    end

    def offline
      respond_to_with_offline
    end

    def not_found
      respond_to_with_not_found
    end

    def error
      respond_to_with_error
    end

    def switch_locale
      locale = I18n.available_locales.map(&:to_s).include?(params[:locale]) ? params[:locale] : I18n.default_locale.to_s
      @session.user.update(locale: locale) if @session.valid?
      cookies[:lato_locale] = { value: locale, expires: 1.year.from_now }
      respond_to_redirect_same_page
    end

    protected

    # This method set the default locale for the application.
    # The default locale is the locale of the user if exists, otherwise is the default locale of the application.
    def set_default_locale
      I18n.locale = (@session.valid? ? @session.user&.locale : nil) || cookies[:lato_locale] || I18n.default_locale
    end

    def respond_to_redirect_same_page(notice = nil)
      respond_to do |format|
        # Never follow a Referer pointing to another host (open redirect).
        format.html { redirect_back_or_to lato.root_path, allow_other_host: false, notice: notice }
        format.json { render json: {} }
      end
    end

    # Web3 challenge: the signed text binds the signature to this host, a purpose and a short lifetime,
    # so a signature collected by another site can not be replayed here.
    WEB3_MESSAGE_LIFETIME = 5.minutes

    def web3_message_generate(purpose)
      session[:web3_nonce] = [
        "#{request.host} wants you to #{purpose} with your Ethereum account.",
        "",
        "URI: #{request.base_url}",
        "Nonce: #{SecureRandom.hex(16)}",
        "Issued At: #{Time.current.utc.iso8601}"
      ].join("\n")
      session[:web3_nonce_expires_at] = WEB3_MESSAGE_LIFETIME.from_now.to_i
      session[:web3_nonce]
    end

    # Single use: the message is removed from the session whatever the outcome.
    def web3_message_consume
      message = session.delete(:web3_nonce)
      expires_at = session.delete(:web3_nonce_expires_at).to_i
      message if message.present? && Time.current.to_i <= expires_at
    end

    def respond_to_with_offline
      hide_sidebar
      respond_to do |format|
        format.html { render 'lato/errors/offline', status: :service_unavailable }
        format.json { render json: { error: 'Network not available' }, status: :service_unavailable }
      end
    end

    def respond_to_with_not_found
      hide_sidebar
      respond_to do |format|
        format.html { render 'lato/errors/not_found', status: :not_found }
        format.json { render json: { error: 'Resource not found' }, status: :not_found }
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
