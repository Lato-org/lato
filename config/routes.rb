Lato::Engine.routes.draw do
  root 'application#index'

  # Authentication
  ##

  scope :authentication do
    get :signin, to: 'authentication#signin', as: :authentication_signin
    get :signup, to: 'authentication#signup', as: :authentication_signup
    post :signup_action, to: 'authentication#signup_action', as: :authentication_signup_action
  end
end
