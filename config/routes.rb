# config/routes.rb
Rails.application.routes.draw do
  root "tasks#index"

  devise_for :users, controllers: {
    confirmations: "users/confirmations",
    passwords: "users/passwords"
  }

  post "/account/send_change_email", to: "account_settings#send_change_email", as: :send_change_email
  post "/account/send_password_reset", to: "account_settings#send_password_reset", as: :send_password_reset

  resources :profiles do
    collection { post :switch }
    member do
      get :settings
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  resources :teams do
    member do
      get :manage
    end
  end

  get "tasks/slot_tasks", to: "tasks#slot_tasks", as: :slot_tasks

  resources :tasks do
    resources :comments, only: %i[create edit update destroy] do
      resources :reactions, only: :create
    end
  end

  resources :team_memberships, only: %i[create destroy update]

  resources :membership_requests, only: [ :create, :destroy, :update ] do
    member do
      patch :approve
    end
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
