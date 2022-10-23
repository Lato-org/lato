class DashboardController < Lato::ApplicationController
  before_action :authenticate_session

  def index; end
end
