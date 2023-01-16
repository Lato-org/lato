require 'sidekiq/web'

Rails.application.routes.draw do
  mount Lato::Engine => '/lato'
  mount Sidekiq::Web => '/sidekiq'

  root 'application#index'

  # Tutorial controller
  get 'tutorial', to: 'tutorial#index', as: :tutorial
  get 'configuration', to: 'tutorial#configuration', as: :configuration
  get 'customization', to: 'tutorial#customization', as: :customization
  get 'components', to: 'tutorial#components', as: :components
  patch 'components/update_user_action', to: 'tutorial#components_update_user_action', as: :components_update_user_action
  get 'operations', to: 'tutorial#operations', as: :operations
  post 'operations/create_operation_action', to: 'tutorial#operations_create_operation_action', as: :operations_create_operation_action
  get 'actions', to: 'tutorial#actions', as: :actions
  get 'invitations', to: 'tutorial#invitations', as: :invitations
  post 'invitations/create_invite_action', to: 'tutorial#invitations_create_invite_action', as: :invitations_create_invite_action
  patch 'invitations/send_invite_action', to: 'tutorial#invitations_send_invite_action', as: :invitations_send_invite_action
  delete 'invitations/destroy_invite_action', to: 'tutorial#invitations_destroy_invite_action', as: :invitations_destroy_invite_action

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
