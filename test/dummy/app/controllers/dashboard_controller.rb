class DashboardController < ApplicationController
  before_action :authenticate_session
  before_action { active_sidebar(:dashboard) }

  def index; end
end
