module Lato
  module Sessionable
    extend ActiveSupport::Concern

    included do
      before_action do
        @session = Lato::Session.new(cookies.encrypted[:lato_session])
      end
    end

    def authenticate_session
      return true if @session.valid?

      respond_to do |format|
        format.html { redirect_to lato.root_path }
        format.json { render plain: '', status: :unauthorized }
      end

      false
    end

    def not_authenticate_session
      return true unless @session.valid?

      respond_to do |format|
        format.html { redirect_to lato.root_path }
        format.json { render plain: '', status: :unauthorized }
      end

      false
    end

    def limit_requests(limit = 10, time_window = 10.minutes)
      cache_key = "Lato::Sessionable/limit_requests/#{controller_name}/#{action_name}/#{request.remote_ip}"
      attempts = Rails.cache.read(cache_key) || 0
      
      attempts += 1
      Rails.cache.write(cache_key, attempts, expires_in: time_window)
      return true unless attempts >= limit

      respond_to do |format|
        format.html { render plain: "Too many requests, please wait #{time_window.to_i / 60} minutes to retry.", status: :too_many_requests }
        format.json { render json: {}, status: :too_many_requests }
      end

      false
    end

    def session_create(user_id)
      cookies.encrypted[:lato_session] = { value: Lato::Session.generate_session_per_user(user_id), expires: Lato.config.session_lifetime.from_now }
      @session = Lato::Session.new(cookies.encrypted[:lato_session])

      true
    end

    def session_destroy
      cookies.encrypted[:lato_session] = nil

      true
    end
  end
end
