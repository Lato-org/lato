module Lato
  class Session
    def initialize(session)
      @session = parse_session(session)
    end

    def valid?
      record.present?
    end

    def really_valid?
      valid? && user.present?
    end

    def user
      @user ||= record&.user if valid?
    end

    def user_id
      record&.lato_user_id
    end

    def get(key)
      @session&.dig(key) if valid?
    end

    def expires_at
      record&.expires_at
    end

    def update(extra_params)
      return unless valid?

      @session.merge!(extra_params.to_h.except(:user_id, :token, "user_id", "token"))
      @session.to_json
    end

    def grant_security_continuation(action)
      record.update!(security_grant_action: action, security_grant_expires_at: 5.minutes.from_now)
    end

    def security_continuation_action
      current = record
      current.security_grant_action if current&.security_grant_expires_at&.future?
    end

    def consume_security_continuation(action)
      return false unless (current = record)

      Lato::SessionRecord.where(id: current.id, security_grant_action: action).where("security_grant_expires_at > ?", Time.current).update_all(security_grant_action: nil, security_grant_expires_at: nil) == 1
    end

    def clear_security_continuation
      record&.update!(security_grant_action: nil, security_grant_expires_at: nil)
    end

    def set_security_challenge(challenge)
      record.update!(security_challenge: challenge, security_challenge_expires_at: 5.minutes.from_now)
    end

    def take_security_challenge
      current = record
      return unless current

      current.with_lock do
        challenge = current.security_challenge if current.security_challenge_expires_at&.future?
        current.update!(security_challenge: nil, security_challenge_expires_at: nil)
        challenge
      end
    end

    def destroy
      record&.destroy!
      @session = nil
    end

    def self.generate_session_per_user(user_id, extra_params = {})
      user = Lato::User.find(user_id)
      token = SecureRandom.hex(32)
      user.with_lock do
        user.lato_session_records.where("expires_at <= ?", Time.current).delete_all
        user.lato_session_records.create!(token_digest: Digest::SHA256.hexdigest(token), expires_at: Lato.config.session_lifetime.from_now)
      end
      extra_params.to_h.except(:user_id, :token, "user_id", "token").merge(user_id: user.id, token: token).to_json
    end

    private

    # Always query revocation state, including when a Session instance was already used.
    def record
      return unless @session&.dig(:token).is_a?(String) && @session[:token].present?

      Lato::SessionRecord.where(lato_user_id: @session[:user_id], token_digest: Digest::SHA256.hexdigest(@session[:token])).where("expires_at > ?", Time.current).first
    end

    def parse_session(session)
      return if session.blank?

      parsed = session.is_a?(String) ? JSON.parse(session) : session
      parsed.with_indifferent_access if parsed.is_a?(Hash)
    rescue JSON::ParserError
      nil
    end
  end
end
