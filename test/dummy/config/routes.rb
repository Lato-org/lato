Rails.application.routes.draw do
  mount Lato::Engine => '/lato'

  root 'application#index'

  get 'dashboard', to: 'dashboard#index', as: :dashboard
end
