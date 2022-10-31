Lato::Engine.routes.draw do
  root 'application#index'

  # Authentication
  ##

  scope :authentication do
    get :signin, to: 'authentication#signin', as: :authentication_signin
    post :signin_action, to: 'authentication#signin_action', as: :authentication_signin_action
    get :signup, to: 'authentication#signup', as: :authentication_signup
    post :signup_action, to: 'authentication#signup_action', as: :authentication_signup_action
    get :signout, to: 'authentication#signout', as: :authentication_signout
    delete :signout_action, to: 'authentication#signout_action', as: :authentication_signout_action
    get :verify_email, to: 'authentication#verify_email', as: :authentication_verify_email
    patch :verify_email_action, to: 'authentication#verify_email_action', as: :authentication_verify_email_action
  end

  scope :account do
    get '', to: 'account#index', as: :account
    patch :update_user_action, to: 'account#update_user_action', as: :account_update_user_action
    patch :request_verify_email_action, to: 'account#request_verify_email_action', as: :account_request_verify_email_action
    patch :update_password_action, to: 'account#update_password_action', as: :account_update_password_action
  end
end
