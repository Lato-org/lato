module Lato
  class AuthenticationController < ApplicationController
    def signin
      @user = Lato::User.new
    end

    def signup
      @user = Lato::User.new(email: 'me@gregoriogalante.com', first_name: 'Greg', last_name: 'Greg')
    end

    def signup_action
      @user = Lato::User.new(params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation))

      respond_to do |format|
        if @user.save
          format.html { redirect_to lato.root_path }
          format.json { render json: @user }
        else
          format.html { render :signup, status: :unprocessable_entity }
          format.json { render json: @model.errors, status: :unprocessable_entity }
        end
      end
    end
  end
end
