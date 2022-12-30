module Lato
  class AuthenticationController < ApplicationController
    before_action :not_authenticate_session, only: %i[signin signin_action signup signup_action]
    before_action :authenticate_session, only: %i[signout signout_action]
    before_action :find_user, only: %i[verify_email verify_email_action update_password update_password_action]
    before_action :hide_sidebar
    before_action :lock_signup_if_disabled, only: %i[signup signup_action]
    before_action :lock_recover_password_if_disabled, only: %i[recover_password recover_password_action update_password update_password_action]

    def signin
      @user = Lato::User.new
    end

    def signin_action
      @user = Lato::User.new

      respond_to do |format|
        if @user.signin(params.require(:user).permit(:email, :password))
          session_create(@user.id)

          format.html { redirect_to lato.root_path }
          format.json { render json: @user }
        else
          format.html { render :signin, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    def signup
      @user = Lato::User.new
    end

    def signup_action
      @user = Lato::User.new(params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :accepted_privacy_policy_version, :accepted_terms_and_conditions_version))

      respond_to do |format|
        if @user.save
          session_create(@user.id)

          format.html { redirect_to lato.root_path }
          format.json { render json: @user }
        else
          format.html { render :signup, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    def signout; end

    def signout_action
      session_destroy

      respond_to do |format|
        format.html { redirect_to lato.root_path }
        format.json { render json: {} }
      end
    end

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

    private

    def find_user
      @user = User.find_by(id: params[:id])
      respond_to_with_not_found unless @user
    end

    def lock_signup_if_disabled
      return unless Lato.config.auth_disable_signup

      respond_to_with_not_found 
    end

    def lock_recover_password_if_disabled
      return unless Lato.config.auth_disable_recover_password

      respond_to_with_not_found 
    end
  end
end
