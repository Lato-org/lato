Rails.application.routes.draw do
  mount Lato::Engine => '/lato'

  root 'application#index'

  # Tutorial controller
  get 'tutorial', to: 'tutorial#index', as: :tutorial
  get 'configuration', to: 'tutorial#configuration', as: :configuration
  get 'customization', to: 'tutorial#customization', as: :customization
  get 'components', to: 'tutorial#components', as: :components
  patch 'components/update_user_action', to: 'tutorial#update_user_action', as: :components_update_user_action

  # Products controller (Complete CRUD example)
  scope :products do
    get '', to: 'products#index', as: :products
    get 'create', to: 'products#create', as: :products_create
    post 'create_action', to: 'products#create_action', as: :products_create_action
    get 'update/:id', to: 'products#update', as: :products_update
    patch 'update_action/:id', to: 'products#update_action', as: :products_update_action
    post 'export_action', to: 'products#export_action', as: :products_export_action
  end
end
