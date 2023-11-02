module Lato
  class Session
    def initialize(session)
      @session = parse_session(session)
    end

    # Questions
    ##

    def valid?
      !@session.blank?
    end

    def really_valid?
      !!user
    end

    # Helpers
    ##

    def user
      @user ||= Lato::User.find_by(id: user_id)
    end

    def user_id
      @session&.dig(:user_id)
    end

    def get(key)
      @session&.dig(key)
    end

    # Class
    ##

    def self.generate_session_per_user(user_id, extra_params = {})
      extra_params.merge(user_id: user_id).to_json
    end

    private

    def parse_session(session)
      return nil if session.blank?

      (session.is_a?(String) ? JSON.parse(session) : session).with_indifferent_access
    end
  end
end