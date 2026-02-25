Rails.application.routes.draw do
  
  # Root route
  root "home#index"
  
  # Registration routes
  get 'register', to: 'users#new'
  post 'register', to: 'users#create'
  
  # Login/logout routes
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  
  # Dashboard routes (protected)
  get 'dashboard', to: 'dashboard#index'
  get 'dashboard/customers', to: 'dashboard#customers'
  get 'dashboard/loans', to: 'dashboard#loans'
  get 'dashboard/records', to: 'dashboard#records'
  get 'dashboard/reports', to: 'dashboard#reports'

  #customers
  resources :customers
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end