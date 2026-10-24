module Lato
  class AccountController < ApplicationController
    before_action :authenticate_session
    before_action { active_navbar(:account) }

    before_action :discard_expired_security_enrollment
    before_action :limit_requests, only: %i[update_user_action update_password_action update_authenticator_action update_webauthn_action update_web3_action destroy_action security_challenge]
    before_action :reauthenticate_sensitive_action, only: %i[update_user_action update_password_action update_authenticator_action update_webauthn_action update_web3_action destroy_action]

    def index; end

    def security_challenge
      return head :not_found unless @session.user.webauthn_enabled?

      options = @session.user.webauthn_authentication_options
      @session.set_security_challenge(options.challenge)
      render json: options.as_json
    end

    def update_user_action
      respond_to do |format|
        if @session.user.update(params.require(:user).permit(:first_name, :last_name, :email))
          format.html { redirect_to lato.account_path, notice: I18n.t('lato.account_controller.update_user_action_notice') }
          format.json { render json: @session.user }
        else
          format.html { render :index, status: :unprocessable_entity }
          format.json { render json: @session.user.errors, status: :unprocessable_entity }
        end
      end
    end

    def update_authenticator_action
      return respond_to_with_not_found unless Lato.config.authenticator_connection

      user = @session.user
      if user.authenticator_enabled?
        success = user.remove_authenticator_secret
      elsif params.dig(:user, :authenticator_command) == "confirm"
        pending = session.delete(:pending_authenticator_secret)
        success = pending.present? && ROTP::TOTP.new(pending).verify(params.dig(:user, :authenticator_code).to_s)
        success = user.update(authenticator_secret: pending) if success
        user.errors.add(:base, :authenticator_code_invalid) unless success
        @session.clear_security_continuation
      else
        session[:pending_authenticator_secret] = ROTP::Base32.random
        grant_security_continuation
        return respond_to do |format|
          format.html { redirect_to lato.account_path }
          format.json { render json: { secret: session[:pending_authenticator_secret] } }
        end
      end

      respond_to do |format|
        if success
          format.html { redirect_to lato.account_path }
          format.json { render json: user }
        else
          format.html { render :index, status: :unprocessable_entity }
          format.json { render json: user.errors, status: :unprocessable_entity }
        end
      end
    end

    def update_webauthn_action
      return respond_to_with_not_found unless Lato.config.webauthn_connection

      respond_to do |format|
        command = params.dig(:user, :webauthn_command)

        case command
        when 'remove'
          if @session.user.remove_webauthn_credential
            reset_webauthn_registration_state
            format.html { redirect_to lato.account_path }
            format.json { render json: @session.user }
          else
            format.html { render :index, status: :unprocessable_entity }
            format.json { render json: @session.user.errors, status: :unprocessable_entity }
          end
        when 'cancel'
          reset_webauthn_registration_state
          format.html { redirect_to lato.account_path }
          format.json { render json: {} }
        when 'complete'
          permitted = params.require(:user).permit(:webauthn_credential)

          if @session.user.register_webauthn_credential(permitted[:webauthn_credential], session[:webauthn_registration_challenge])
            reset_webauthn_registration_state
            format.html { redirect_to lato.account_path }
            format.json { render json: @session.user }
          else
            reset_webauthn_registration_state
            format.html { render :index, status: :unprocessable_entity }
            format.json { render json: @session.user.errors, status: :unprocessable_entity }
          end
        else
          grant_security_continuation
          options = @session.user.webauthn_registration_options
          session[:webauthn_registration_challenge] = Base64.strict_encode64(options.challenge)
          session[:webauthn_registration_options] = options.as_json
          format.html { redirect_to lato.account_path }
          format.json { render json: { options: session[:webauthn_registration_options] } }
        end
      end
    rescue StandardError => e
      Rails.logger.error(e)
      reset_webauthn_registration_state
      respond_to do |format|
        format.html { render :index, status: :unprocessable_entity }
        format.json { render json: { error: :webauthn_unexpected_error }, status: :unprocessable_entity }
      end
    end

    def update_web3_action
      return respond_to_with_not_found unless Lato.config.web3_connection

      if @session.user.web3_address
        respond_to do |format|
          if @session.user.remove_web3_connection
            format.html { redirect_to lato.account_path }
            format.json { render json: @session.user }
          else
            format.html { render :index, status: :unprocessable_entity }
            format.json { render json: @session.user.errors, status: :unprocessable_entity }
          end
        end
      elsif session[:web3_nonce]
        respond_to do |format|
          if @session.user.add_web3_connection(params.require(:user).permit(:web3_address, :web3_signed_nonce).merge(web3_nonce: session[:web3_nonce]))
            session[:web3_nonce] = nil
            format.html { redirect_to lato.account_path }
            format.json { render json: @session.user }
          else
            session[:web3_nonce] = nil
            format.html { render :index, status: :unprocessable_entity }
            format.json { render json: @session.user.errors, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
          grant_security_continuation
          if session[:web3_nonce] = SecureRandom.hex(32)
            format.html { redirect_to lato.account_path }
            format.json { render json: @session.user }
          else
            format.html { render :index, status: :unprocessable_entity }
            format.json { render json: @session.user.errors, status: :unprocessable_entity }
          end
        end
      end
    end

    def request_verify_email_action
      respond_to do |format|
        if @session.user.request_verify_email
          format.html { redirect_to lato.account_path, notice: I18n.t('lato.account_controller.request_verify_email_action_notice') }
          format.json { render json: @session.user }
        else
          format.html { render :index, status: :unprocessable_entity }
          format.json { render json: @session.user.errors, status: :unprocessable_entity }
        end
      end
    end

    def update_password_action
      respond_to do |format|
        if @session.user.update(params.require(:user).permit(:password, :password_confirmation))
          session_destroy
          format.html { redirect_to lato.authentication_signin_path, notice: I18n.t('lato.account_controller.update_password_action_notice') }
          format.json { render json: {} }
        else
          format.html { render :index, status: :unprocessable_entity }
          format.json { render json: @session.user.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy_action
      respond_to do |format|
        if @session.user.destroy_with_confirmation(params.require(:user).permit(:email_confirmation))
          session_destroy

          format.html { redirect_to lato.root_path }
          format.json { render json: {} }
        else
          format.html { render :index, status: :unprocessable_entity }
          format.json { render json: @session.user.errors, status: :unprocessable_entity }
        end
      end
    end

    def update_accepted_privacy_policy_version_action
      respond_to do |format|
        if @session.user.update_accepted_privacy_policy_version(params.require(:user).permit(:confirm))
          format.html { redirect_to lato.account_path }
          format.json { render json: @session.user }
        else
          format.html { render :index, status: :unprocessable_entity }
          format.json { render json: @session.user.errors, status: :unprocessable_entity }
        end
      end
    end

    def update_accepted_terms_and_conditions_version_action
      respond_to do |format|
        if @session.user.update_accepted_terms_and_conditions_version(params.require(:user).permit(:confirm))
          format.html { redirect_to lato.account_path }
          format.json { render json: @session.user }
        else
          format.html { render :index, status: :unprocessable_entity }
          format.json { render json: @session.user.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def discard_expired_security_enrollment
      action = @session.security_continuation_action
      session.delete(:pending_authenticator_secret) unless action == "update_authenticator_action"
      unless action == "update_webauthn_action"
        session.delete(:webauthn_registration_challenge)
        session.delete(:webauthn_registration_options)
      end
      session.delete(:web3_nonce) unless action == "update_web3_action"
    end

    def reauthenticate_sensitive_action
      if action_name == "update_user_action"
        email = params.dig(:user, :email)
        return if email.nil? || email.to_s.downcase.strip == @session.user.email
      end
      return if action_name == "update_webauthn_action" && params.dig(:user, :webauthn_command) == "cancel"

      continuation = case action_name
      when "update_authenticator_action"
        params.dig(:user, :authenticator_command) == "confirm"
      when "update_webauthn_action"
        params.dig(:user, :webauthn_command) == "complete"
      when "update_web3_action"
        session[:web3_nonce].present?
      end
      return if continuation && @session.consume_security_continuation(action_name)

      user = @session.user
      password_valid = user.authenticate(params.dig(:user, :current_password).to_s)
      factor_valid = if user.authenticator_enabled?
        user.authenticator(authenticator_code: params.dig(:user, :current_authenticator_code).to_s)
      elsif user.webauthn_enabled?
        challenge = @session.take_security_challenge
        user.webauthn_authentication({ webauthn_credential: params.dig(:user, :current_webauthn_credential) }, challenge)
      else
        true
      end
      return if password_valid && factor_valid

      user.errors.add(:base, "Confirm your current password and enabled second factor to continue.")
      respond_to do |format|
        format.html { render :index, status: :unprocessable_entity }
        format.json { render json: user.errors, status: :unprocessable_entity }
      end
    end

    def grant_security_continuation
      @session.grant_security_continuation(action_name)
    end

    def reset_webauthn_registration_state
      @session.clear_security_continuation
      session[:webauthn_registration_challenge] = nil
      session[:webauthn_registration_options] = nil
    end
  end
end
