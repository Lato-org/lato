module Lato
  class AuthenticationController < ApplicationController
    before_action :limit_requests, only: %i[signin_action signup_action accept_invitation_action recover_password_action update_password_action]
    before_action :not_authenticate_session, only: %i[signin signin_action signup signup_action accept_invitation accept_invitation_action]
    before_action :authenticate_session, only: %i[signout signout_action]

    before_action :find_user, only: %i[verify_email verify_email_action update_password update_password_action]
    before_action :find_invitation, only: %i[accept_invitation accept_invitation_action]

    before_action :lock_signup_if_disabled, only: %i[signup signup_action]
    before_action :lock_recover_password_if_disabled, only: %i[recover_password recover_password_action update_password update_password_action]
    before_action :lock_web3_if_disabled, only: %i[web3_signin web3_signin_action]
    before_action :lock_authenticator_if_disabled, only: %i[authenticator authenticator_action]

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
          if create_session_or_start_authenticator(@user)
            format.html { redirect_to lato.root_path }
            format.json { render json: @user }
          else
            format.html { redirect_to lato.authentication_authenticator_path }
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
          if create_session_or_start_authenticator(@user)
            format.html { redirect_to lato.root_path }
            format.json { render json: @user }
          else
            format.html { redirect_to lato.authentication_authenticator_path }
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

    # Authenticator
    ##

    def authenticator
      @user = Lato::User.find_by_id(session[:authenticator_user_id])
      return respond_to_with_not_found unless @user
    end

    def authenticator_action
      @user = Lato::User.find_by_id(session[:authenticator_user_id])

      respond_to do |format|
        if @user.authenticator(params.require(:user).permit(:authenticator_code))
          session[:authenticator_user_id] = nil
          session_create(@user.id)

          format.html { redirect_to lato.root_path }
          format.json { render json: @user }
        else
          format.html { render :authenticator, status: :unprocessable_entity }
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

    def create_session_or_start_authenticator(user)
      if !Lato.config.authenticator_connection || Lato.config.auth_disable_authenticator || !user.authenticator_enabled?
        session_create(user.id)
        return true
      end

      session[:authenticator_user_id] = user.id
      false
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
  end
end
