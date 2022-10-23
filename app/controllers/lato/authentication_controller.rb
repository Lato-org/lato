module Lato
  class AuthenticationController < ApplicationController
    def signin
      @user = Lato::User.new
    end

    def signup
      @user = Lato::User.new
    end
  end
end
