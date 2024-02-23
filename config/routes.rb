Lato::Engine.routes.draw do
  root 'application#index'
  get 'offline', to: 'application#offline', as: :offline
  get 'not_found', to: 'application#not_found', as: :not_found
  get 'error', to: 'application#error', as: :error

  post '/switch_locale/:locale', to: 'application#switch_locale', as: 'switch_locale'

  # Authentication
  ##

  scope :authentication do
    get 'signin', to: 'authentication#signin', as: :authentication_signin
    post 'signin_action', to: 'authentication#signin_action', as: :authentication_signin_action
    get 'web3_signin', to: 'authentication#web3_signin', as: :authentication_web3_signin
    post 'web3_signin_action', to: 'authentication#web3_signin_action', as: :authentication_web3_signin_action
    get 'signup', to: 'authentication#signup', as: :authentication_signup
    post 'signup_action', to: 'authentication#signup_action', as: :authentication_signup_action
    get 'signout', to: 'authentication#signout', as: :authentication_signout
    delete 'signout_action', to: 'authentication#signout_action', as: :authentication_signout_action
    get 'verify_email', to: 'authentication#verify_email', as: :authentication_verify_email
    patch 'verify_email_action', to: 'authentication#verify_email_action', as: :authentication_verify_email_action
    get 'recover_password', to: 'authentication#recover_password', as: :authentication_recover_password
    post 'recover_password_action', to: 'authentication#recover_password_action', as: :authentication_recover_password_action
    get 'update_password', to: 'authentication#update_password', as: :authentication_update_password
    patch 'update_password_action', to: 'authentication#update_password_action', as: :authentication_update_password_action
    get 'accept_invitation', to: 'authentication#accept_invitation', as: :authentication_accept_invitation
    post 'accept_invitation_action', to: 'authentication#accept_invitation_action', as: :authentication_accept_invitation_action
  end

  # Account
  ##

  scope :account do
    get '', to: 'account#index', as: :account
    patch 'update_user_action', to: 'account#update_user_action', as: :account_update_user_action
    patch 'update_web3_action', to: 'account#update_web3_action', as: :account_update_web3_action
    patch 'request_verify_email_action', to: 'account#request_verify_email_action', as: :account_request_verify_email_action
    patch 'update_password_action', to: 'account#update_password_action', as: :account_update_password_action
    delete 'destroy_action', to: 'account#destroy_action', as: :account_destroy_action
    patch 'update_accepted_privacy_policy_version_action', to: 'account#update_accepted_privacy_policy_version_action', as: :account_update_accepted_privacy_policy_version_action
    patch 'update_accepted_terms_and_conditions_version_action', to: 'account#update_accepted_terms_and_conditions_version_action', as: :account_update_accepted_terms_and_conditions_version_action
  end

  # Operations
  ##

  get 'operation/:id', to: 'operations#show', as: :operation

  # NOTE: Legacy route
  get 'operations/show/:id', to: 'operations#show_legacy', as: :operations_show
end
