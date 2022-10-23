module Lato
  # Config
  # This class contains the default configuration of the engine.
  ##
  class Config
    attr_accessor :application_title, :application_company_name, :application_company_url

    def initialize
      @application_title = 'Lato'
      @application_company_name = 'Lato Team'
      @application_company_url = 'https://github.com/Lato-GAM'
    end
  end
end
