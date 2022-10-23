module Lato
  class Session
    def initialize(session)
      @session = session
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
      @user ||= Lato::User.find_by(id: @session)
    end

    def user_id
      @session
    end

    # Class
    ##

    def self.generate_session_per_user(user_id)
      user_id
    end
  end
end