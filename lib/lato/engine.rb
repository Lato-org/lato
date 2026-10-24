require 'webauthn'

module Lato
  class Engine < ::Rails::Engine
    isolate_namespace Lato

    initializer 'lato.importmap', before: 'importmap' do |app|
      app.config.importmap.paths << root.join('config/importmap.rb')
    end

    initializer "lato.precompile" do |app|
      app.config.assets.precompile << "lato_manifest.js"
    end

    initializer "lato.filter_credentials" do |app|
      app.config.filter_parameters += %i[current_password current_authenticator_code current_webauthn_credential authenticator_code authenticator_secret webauthn_credential web3_signed_nonce code accepted_code]
    end

    config.after_initialize do
      if Lato.config.webauthn_connection
        WebAuthn.configure do |config|
          config.allowed_origins = Lato.config.webauthn_origin.is_a?(Array) ? Lato.config.webauthn_origin : [Lato.config.webauthn_origin]
          config.rp_name = Lato.config.webauthn_rp_name
        end
      end
    end
  end
end
