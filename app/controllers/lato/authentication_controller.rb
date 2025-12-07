module Lato
  class AuthenticationController < ApplicationController
    before_action :limit_requests, only: %i[signin_action signup_action accept_invitation_action recover_password_action update_password_action]
    before_action :not_authenticate_session, only: %i[signin signin_action signup signup_action accept_invitation accept_invitation_action]
    before_action :authenticate_session, only: %i[signout signout_action]

    before_action :find_user, only: %i[verify_email verify_email_action update_password update_password_action]
    before_action :find_invitation, only: %i[accept_invitation accept_invitation_action]
    before_action :find_authentication_user, only: %i[authentication_method authentication_method_action webauthn webauthn_action]

    before_action :lock_signup_if_disabled, only: %i[signup signup_action]
    before_action :lock_recover_password_if_disabled, only: %i[recover_password recover_password_action update_password update_password_action]
    before_action :lock_web3_if_disabled, only: %i[web3_signin web3_signin_action]
    before_action :lock_authenticator_if_disabled, only: %i[authenticator authenticator_action]
    before_action :lock_webauthn_if_disabled, only: %i[webauthn webauthn_action]

    before_action :hide_sidebar

    # Signin
    ##

    def signin
      @user = Lato::User.new
    end

    def signin_action
      @user = Lato::User.new

      respond_to do |format|
        if @user.signin(params.require(:user).permit(:email, :password).merge(
          ip_address: request.remote_ip,
          user_agent: request.user_agent
        ))
          redirect_path = determine_authentication_redirect(@user)
          if redirect_path
            format.html { redirect_to redirect_path }
            format.json { render json: @user }
          else
            session_create(@user.id)
            format.html { redirect_to lato.root_path }
            format.json { render json: @user }
          end
        else
          format.html { render :signin, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    def web3_signin
      @user = Lato::User.new
      session[:web3_nonce] = SecureRandom.hex(32)
    end

    def web3_signin_action
      @user = Lato::User.new

      respond_to do |format|
        if @user.web3_signin(params.require(:user).permit(:web3_address, :web3_signed_nonce).merge(
          ip_address: request.remote_ip,
          user_agent: request.user_agent,
          web3_nonce: session[:web3_nonce]
        ))
          session[:web3_nonce] = nil
          redirect_path = determine_authentication_redirect(@user)
          if redirect_path
            format.html { redirect_to redirect_path }
            format.json { render json: @user }
          else
            session_create(@user.id)
            format.html { redirect_to lato.root_path }
            format.json { render json: @user }
          end
        else
          session[:web3_nonce] = nil
          format.html { render :web3_signin, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    # Signup
    ##

    def signup
      @user = Lato::User.new
    end

    def signup_action
      @user = Lato::User.new(registration_params)
      return unless verify_hcaptcha(:signup)

      respond_to do |format|
        if @user.signup(ip_address: request.remote_ip, user_agent: request.user_agent)
          session_create(@user.id)

          format.html { redirect_to lato.root_path }
          format.json { render json: @user }
        else
          format.html { render :signup, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    # Signout
    ##

    def signout; end

    def signout_action
      session_destroy

      respond_to do |format|
        format.html { redirect_to lato.root_path }
        format.json { render json: {} }
      end
    end

    # Verify email
    ##

    def verify_email
      @code = params[:code]
    end

    def verify_email_action
      respond_to do |format|
        if @user.verify_email(params.require(:user).permit(:code))
          format.html { redirect_to lato.root_path, notice: I18n.t('lato.authentication_controller.verify_email_action_notice') }
          format.json { render json: @user }
        else
          format.html { render :verify_email, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    # Recover password
    ##

    def recover_password
      @user = Lato::User.new
    end

    def recover_password_action
      @user = Lato::User.new

      respond_to do |format|
        if @user.request_recover_password(params.require(:user).permit(:email))
          format.html { redirect_to lato.authentication_update_password_path(id: @user.id) }
          format.json { render json: @user }
        else
          format.html { render :recover_password, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    # Update password
    ##

    def update_password; end

    def update_password_action
      respond_to do |format|
        if @user.update_password(params.require(:user).permit(:code, :password, :password_confirmation))
          format.html { redirect_to lato.authentication_signin_path, notice: I18n.t('lato.authentication_controller.update_password_action_notice') }
          format.json { render json: @user }
        else
          format.html { render :update_password, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    # Accept invitation
    ##

    def accept_invitation
      @user = Lato::User.new(email: @invitation.email)
    end

    def accept_invitation_action
      @user = Lato::User.new(registration_params)

      respond_to do |format|
        if @user.accept_invitation(params.permit(:id, :accepted_code))
          session_create(@user.id)

          format.html { redirect_to lato.root_path }
          format.json { render json: @user }
        else
          format.html { render :accept_invitation, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    # Authentication method choice
    ##

    def authentication_method; end

    def authentication_method_action
      method = params[:method]
      
      respond_to do |format|
        case method
        when 'authenticator'
          session[:authentication_method] = 'authenticator'
          format.html { redirect_to lato.authentication_authenticator_path }
          format.json { render json: { redirect: lato.authentication_authenticator_path } }
        when 'webauthn'
          session[:authentication_method] = 'webauthn'
          format.html { redirect_to lato.authentication_webauthn_path }
          format.json { render json: { redirect: lato.authentication_webauthn_path } }
        else
          format.html { redirect_to lato.authentication_signin_path }
          format.json { render json: { error: 'Invalid method' }, status: :unprocessable_entity }
        end
      end
    end

    # Authenticator
    ##

    def authenticator
      @user = Lato::User.find_by_id(session[:authentication_user_id])
      return respond_to_with_not_found unless @user
    end

    def authenticator_action
      @user = Lato::User.find_by_id(session[:authentication_user_id])

      respond_to do |format|
        if @user.authenticator(params.require(:user).permit(:authenticator_code))
          clear_authentication_session
          session_create(@user.id)

          format.html { redirect_to lato.root_path }
          format.json { render json: @user }
        else
          format.html { render :authenticator, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    # WebAuthn
    ##

    def webauthn
      @options = @user.webauthn_authentication_options
      session[:webauthn_challenge] = @options.challenge
    end

    def webauthn_action
      respond_to do |format|
        if @user.webauthn_authentication(params.require(:user).permit(:webauthn_credential), session[:webauthn_challenge])
          clear_authentication_session
          session_create(@user.id)

          format.html { redirect_to lato.root_path }
          format.json { render json: @user }
        else
          @options = @user.webauthn_authentication_options
          session[:webauthn_challenge] = @options.challenge
          format.html { render :webauthn, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def registration_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :accepted_privacy_policy_version, :accepted_terms_and_conditions_version)
    end

    def find_user
      @user = User.find_by(id: params[:id])
      respond_to_with_not_found unless @user
    end

    def find_invitation
      @invitation = Lato::Invitation.find_by(id: params[:id], accepted_code: params[:accepted_code])
      respond_to_with_not_found unless @invitation
    end

    def find_authentication_user
      @user = Lato::User.find_by_id(session[:authentication_user_id])
      respond_to_with_not_found unless @user
    end

    def determine_authentication_redirect(user)
      authenticator_enabled = Lato.config.authenticator_connection && !Lato.config.auth_disable_authenticator && user.authenticator_enabled?
      webauthn_enabled = Lato.config.webauthn_connection && !Lato.config.auth_disable_webauthn && user.webauthn_enabled?

      return nil unless authenticator_enabled || webauthn_enabled

      session[:authentication_user_id] = user.id

      if authenticator_enabled && webauthn_enabled
        lato.authentication_authentication_method_path
      elsif authenticator_enabled
        lato.authentication_authenticator_path
      elsif webauthn_enabled
        lato.authentication_webauthn_path
      end
    end

    def clear_authentication_session
      session[:authentication_user_id] = nil
      session[:authentication_method] = nil
      session[:webauthn_challenge] = nil
    end

    def lock_signup_if_disabled
      return unless Lato.config.auth_disable_signup

      respond_to_with_not_found
    end

    def lock_recover_password_if_disabled
      return unless Lato.config.auth_disable_recover_password

      respond_to_with_not_found
    end

    def lock_web3_if_disabled
      return if Lato.config.web3_connection && !Lato.config.auth_disable_web3


      respond_to_with_not_found
    end

    def lock_authenticator_if_disabled
      return if Lato.config.authenticator_connection && !Lato.config.auth_disable_authenticator

      respond_to_with_not_found
    end

    def lock_webauthn_if_disabled
      return if Lato.config.webauthn_connection && !Lato.config.auth_disable_webauthn

      respond_to_with_not_found
    end

    def verify_hcaptcha(render_key)
      return true unless Lato.config.hcaptcha_site_key && Lato.config.hcaptcha_secret

      # Per compatibilità con i vari endpoint, istanzia @user se non esiste
      @user ||= Lato::User.new

      hcaptcha_response = params["h-captcha-response"]
      if hcaptcha_response.blank?
        @user.errors.add(:base, "hCaptcha response is missing")
        respond_to do |format|
          format.html { render render_key, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
        return false
      end

      require 'net/http'
      require 'uri'
      require 'json'
      uri = URI.parse("https://hcaptcha.com/siteverify")
      response = Net::HTTP.post_form(uri, {
        "secret" => Lato.config.hcaptcha_secret,
        "response" => hcaptcha_response,
        "remoteip" => request.remote_ip
      })
      result = JSON.parse(response.body)
      Rails.logger.info("[hCaptcha] Verification result: #{result}")
      unless result["success"]
        @user.errors.add(:base, "hCaptcha verification failed")
        respond_to do |format|
          format.html { render render_key, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
        return false
      end

      true
    end
  end
end
