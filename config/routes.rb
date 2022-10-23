Lato::Engine.routes.draw do
  root 'application#index'

  # Authentication
  ##

  scope :authentication do
    get :signin, to: 'authentication#signin', as: :authentication_signin
    get :signup, to: 'authentication#signup', as: :authentication_signup
  end
end
