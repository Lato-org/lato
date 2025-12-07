Lato.configure do |config|
  config.application_title = 'Lato Documentation'
  config.application_version = Lato::VERSION

  config.session_root_path = :tutorial_path

  config.legal_privacy_policy_url = 'https://github.com/Lato-org'
  config.legal_terms_and_conditions_url = 'https://github.com/Lato-org'
  # config.legal_terms_and_conditions_version = 4
  # config.legal_privacy_policy_version = 4

  config.web3_connection = true
  config.authenticator_connection = true
  config.webauthn_connection = true
  config.webauthn_origin = 'http://localhost:3000'
  config.webauthn_rp_name = 'Lato Documentation'
end
