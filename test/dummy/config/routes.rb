Rails.application.routes.draw do
  mount Lato::Engine => "/lato"

  root 'application#index'
end
