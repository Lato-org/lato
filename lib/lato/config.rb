module Lato
  # Config
  # This class contains the default configuration of the engine.
  ##
  class Config
    # Applicaction configs
    attr_accessor :application_title, :application_company_name, :application_company_url

    # Session configs
    attr_accessor :session_lifetime, :session_root_path

    # Email configs
    attr_accessor :email_from

    # Legal settings
    attr_accessor :legal_privacy_policy_url, :legal_privacy_policy_version, :legal_terms_and_conditions_url, :legal_terms_and_conditions_version

    def initialize
      @application_title = 'Lato'
      @application_company_name = 'Lato Team'
      @application_company_url = 'https://github.com/Lato-GAM'

      @session_lifetime = 30.days
      @session_root_path = nil # :tutorial_path

      @email_from = 'lato@example.com'

      @legal_privacy_policy_url = '#'
      @legal_privacy_policy_version = 1
      @legal_terms_and_conditions_url = '#'
      @legal_terms_and_conditions_version = 1
    end
  end
end
