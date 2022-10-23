module Lato
  class AccountController < ApplicationController
    before_action :authenticate_session

    def index; end
  end
end
