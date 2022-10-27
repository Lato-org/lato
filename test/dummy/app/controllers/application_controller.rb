class ApplicationController < Lato::ApplicationController
  layout 'lato/application'

  def index
    hide_sidebar
  end
end
