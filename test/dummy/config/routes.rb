Rails.application.routes.draw do
  mount Lato::Engine => '/lato'

  root 'application#index'

  get 'dashboard', to: 'dashboard#index', as: :dashboard
  get 'configuration', to: 'dashboard#configuration', as: :configuration
  get 'customization', to: 'dashboard#customization', as: :customization
  get 'components', to: 'dashboard#components', as: :components
end
