module Lato
  class AuthenticationController < ApplicationController
    before_action :not_authenticate_session, only: %i[signin signin_action signup signup_action]
    before_action :authenticate_session, only: %i[signout signout_action]
    before_action :find_user, only: %i[verify_email verify_email_action]
    before_action :hide_sidebar

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
      @user = Lato::User.new(params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation))

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
        format.json { render plain: '' }
      end
    end

    def verify_email
      @code = params[:code]
    end

    def verify_email_action
      respond_to do |format|
        if @user.verify_email(params.permit(:code))
          format.html { redirect_to lato.authentication_verify_email_path(id: @user.id), notice: 'Indirizzo email verificato correttamente' }
          format.json { render json: @user }
        else
          format.html { render :verify_email, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def find_user
      @user = User.find_by(id: params[:id])
      respond_to_with_404 unless @user
    end
  end
end
