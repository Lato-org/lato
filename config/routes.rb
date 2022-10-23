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
  end

  scope :account do
    get '', to: 'account#index', as: :account
  end
end
