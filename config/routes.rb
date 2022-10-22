Lato::Engine.routes.draw do
  # Authentication
  ##

  scope :authentication do
    get :signin, to: 'authentication#signin', as: :authentication_signin
    get :signup, to: 'authentication#signup', as: :authentication_signup
  end
end
