module Lato
  # Config
  # This class contains the default configuration of the engine.
  ##
  class Config
    # Applicaction configs
    attr_accessor :application_title, :application_version, :application_company_name, :application_company_url, :application_brand_color

    # Session configs
    attr_accessor :session_lifetime, :session_root_path

    # Authentication configs
    attr_accessor :auth_disable_signup, :auth_disable_recover_password, :auth_disable_web3, :auth_disable_authenticator

    # Hcaptcha configs
    attr_accessor :hcaptcha_site_key, :hcaptcha_secret

    # Assets configs
    attr_accessor :assets_stylesheet_entry
    attr_accessor :assets_importmap_entry

    # Email configs
    attr_accessor :email_from

    # Legal settings
    attr_accessor :legal_privacy_policy_url, :legal_privacy_policy_version, :legal_terms_and_conditions_url, :legal_terms_and_conditions_version

    # Web3 connection
    # NOTE: It requires the gem 'eth' to be installed in the application Gemfile
    attr_accessor :web3_connection

    # Authenticator connection
    attr_accessor :authenticator_connection

    def initialize
      @application_title = 'Lato'
      @application_version = '1.0.0'
      @application_company_name = 'Lato Team'
      @application_company_url = 'https://github.com/lato-org'
      @application_brand_color = '#03256c'

      @auth_disable_signup = false
      @auth_disable_recover_password = false
      @auth_disable_web3 = false
      @auth_disable_authenticator = false
      
      @hcaptcha_site_key = nil
      @hcaptcha_secret = nil

      @assets_stylesheet_entry = 'application'
      @assets_importmap_entry = 'application'

      @session_lifetime = 30.days
      @session_root_path = nil # :tutorial_path

      @email_from = 'lato@example.com'

      @legal_privacy_policy_url = '#'
      @legal_privacy_policy_version = 1
      @legal_terms_and_conditions_url = '#'
      @legal_terms_and_conditions_version = 1

      @web3_connection = false
      @authenticator_connection = false
    end
  end
end
