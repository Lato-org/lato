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

    def session_create(user_id)
      cookies.encrypted[:lato_session] = { value: Lato::Session.generate_session_per_user(user_id), expires: Lato.config.session_lifetime.from_now }

      true
    end

    def session_destroy
      cookies.encrypted[:lato_session] = nil

      true
    end
  end
end
