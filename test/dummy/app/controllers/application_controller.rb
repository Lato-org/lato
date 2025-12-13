class ApplicationController < Lato::ApplicationController
  layout 'lato/application'

  def index
    hide_sidebar
    page_class 'homepage'
    page_title 'Lato - A Rails engine that includes what you need to build a new project!'
  end
end
