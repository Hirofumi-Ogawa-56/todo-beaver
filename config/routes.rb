# config/routes.rb
Rails.application.routes.draw do
  root "tasks#index"

  devise_for :users, controllers: {
    confirmations: "users/confirmations"
  }

  post "/account/send_change_email", to: "account_settings#send_change_email", as: :send_change_email
  post "/account/send_password_reset", to: "account_settings#send_password_reset", as: :send_password_reset

  resources :profiles do
    collection { post :switch }
  end

  get "up" => "rails/health#show", as: :rails_health_check

  resource :profile_settings, only: [] do
    get :home
    get :edit
    get :theme
  end

  resource :team_settings, only: [] do
    get :home
    get :edit
    get :members
  end

  resources :teams

  get "tasks/slot_tasks", to: "tasks#slot_tasks", as: :slot_tasks

  resources :tasks do
    resources :comments, only: %i[create edit update destroy] do
      resources :reactions, only: :create
    end
  end

  resources :team_memberships, only: %i[create destroy update]

  resources :membership_requests, only: %i[create] do
    member { patch :approve }
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
