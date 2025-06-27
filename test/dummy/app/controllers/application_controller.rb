class ApplicationController < Lato::ApplicationController
  layout 'lato/application'

  def index
    hide_sidebar
    page_class 'homepage'
  end
end
