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
  # Dashboard payments ledger
  get  "dashboard/payments", to: "dashboard#payments", as: :dashboard_payments
  post "dashboard/payments/record", to: "dashboard_payments#record", as: :dashboard_record_payment
  get 'dashboard/records', to: 'dashboard#records'
  get 'dashboard/reports', to: 'dashboard#reports'

  #customers
  resources :customers do
    resources :loans, shallow: true do
      resources :payments, shallow: true
    end
  end
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end