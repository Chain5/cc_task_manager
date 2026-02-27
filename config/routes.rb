Rails.application.routes.draw do
  root "tasks#index"

  # Authentication
  get    "/login",  to: "sessions#new",           as: :login
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy",        as: :logout
  get    "/signup", to: "registrations#new",       as: :signup
  post   "/signup", to: "registrations#create"

  resources :tasks do
    resources :comments, only: %i[create destroy]
    member do
      patch :advance_status
      patch :move
    end
  end

  # Health check (Rails 8 default)
  get "up" => "rails/health#show", as: :rails_health_check
end
