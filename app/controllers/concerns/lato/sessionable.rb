module Lato
  module Sessionable
    extend ActiveSupport::Concern

    included do
      before_action do
        @session = Lato::Session.new(cookies.encrypted[:lato_session])
        @session.track_activity
      end
    end

    def authenticate_session
      return true if @session.really_valid?

      respond_to do |format|
        format.html { redirect_to lato.root_path }
        format.json { render plain: '', status: :unauthorized }
      end

      false
    end

    def not_authenticate_session
      return true unless @session.really_valid?

      respond_to do |format|
        format.html { redirect_to lato.root_path }
        format.json { render plain: '', status: :unauthorized }
      end

      false
    end

    def limit_requests(limit = 10, time_window = 10.minutes)
      cache_key = "Lato::Sessionable/limit_requests/#{controller_name}/#{action_name}/#{request.remote_ip}"
      # increment is atomic on shared stores, so parallel requests can not slip past the limit.
      attempts = Rails.cache.increment(cache_key, 1, expires_in: time_window).to_i
      return true if attempts <= limit

      respond_to_too_many_requests(time_window)
      false
    end

    # Per-account throttle on failed attempts: complements the per-IP limit against distributed brute force.
    ACCOUNT_LIMIT_ATTEMPTS = 10
    ACCOUNT_LIMIT_TIME_WINDOW = 15.minutes

    def account_limit_reached?(identifier)
      return false if identifier.blank?

      reached = Rails.cache.read(account_limit_cache_key(identifier), raw: true).to_i >= ACCOUNT_LIMIT_ATTEMPTS
      respond_to_too_many_requests(ACCOUNT_LIMIT_TIME_WINDOW) if reached
      reached
    end

    def account_limit_track_failure(identifier)
      return if identifier.blank?

      Rails.cache.increment(account_limit_cache_key(identifier), 1, expires_in: ACCOUNT_LIMIT_TIME_WINDOW)
    end

    def account_limit_reset(identifier)
      Rails.cache.delete(account_limit_cache_key(identifier)) if identifier.present?
    end

    def account_limit_cache_key(identifier)
      "Lato::Sessionable/account_limit/#{Digest::SHA256.hexdigest(identifier.to_s.downcase.strip)}"
    end

    def respond_to_too_many_requests(time_window)
      message = I18n.t('lato.too_many_requests', minutes: (time_window.to_i / 60.0).ceil)
      respond_to do |format|
        format.html { render plain: message, status: :too_many_requests }
        format.json { render json: { error: message }, status: :too_many_requests }
      end
    end

    def session_create(user_id)
      @session&.destroy
      reset_session
      write_session_cookie(Lato::Session.generate_session_per_user(user_id))
    end

    def session_update(extra_params)
      value = @session.update(extra_params)
      return false unless value

      write_session_cookie(value)
    end

    def write_session_cookie(value)
      @session = Lato::Session.new(value)
      cookies.encrypted[:lato_session] = {
        value: value,
        expires: @session.expires_at,
        httponly: true,
        secure: request.ssl?,
        same_site: :lax
      }
      true
    end

    def session_destroy
      @session&.destroy
      cookies.delete(:lato_session)
      reset_session

      true
    end
  end
end
