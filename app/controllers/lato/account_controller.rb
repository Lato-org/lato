module Lato
  class AccountController < ApplicationController
    before_action :authenticate_session
    before_action { active_navbar(:account) }

    def index; end

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

    def update_web3_action
      if @session.user.web3_connection_completed?
        respond_to do |format|
          if @session.user.remove_web3_connection
            format.html { redirect_to lato.account_path }
            format.json { render json: @session.user }
          else
            format.html { render :index, status: :unprocessable_entity }
            format.json { render json: @session.user.errors, status: :unprocessable_entity }
          end
        end
      elsif @session.user.web3_connection_started?
        respond_to do |format|
          if @session.user.complete_web3_connection(params.require(:user).permit(:web3_address, :web3_signed_nonce))
            format.html { redirect_to lato.account_path }
            format.json { render json: @session.user }
          else
            format.html { render :index, status: :unprocessable_entity }
            format.json { render json: @session.user.errors, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
          if @session.user.start_web3_connection
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
          format.html { redirect_to lato.account_path, notice: I18n.t('lato.account_controller.update_password_action_notice') }
          format.json { render json: @session.user }
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
  end
end
