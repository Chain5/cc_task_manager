Rails.application.routes.draw do
  root "tasks#index"

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
