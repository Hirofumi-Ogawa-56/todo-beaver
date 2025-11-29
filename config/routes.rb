# config/routes.rb

Rails.application.routes.draw do
  get "teams/index"
  get "teams/show"
  get "teams/new"
  get "teams/edit"
  # トップページ/にアクセスが来たら、HomeControllerのindexを呼び出す
  root "tasks#index"

  # deviseにUserモデル用の認証ルートをまとめて生成する
  devise_for :users

  # Profile用のルートをRESTfulにまとめて生成し、プロファイル切り替え（switch）を追加する
  resources :profiles do
    collection do
      post :switch  # /profiles/switch
    end
  end

  # /up というパスに GET が来たら、Rails::HealthController の show アクションを呼ぶ。
  get "up" => "rails/health#show", as: :rails_health_check

  # Profileのsettingページ
  resource :profile_settings, only: [] do
    get :home          # profile_settings_home_path
    get :edit          # profile_settings_edit_path（プロフィール編集）
    get :theme         # profile_settings_theme_path（プロフィールカラー）
  end

  # Teamのsettingページ
  resource :team_settings, only: [] do
    get :home          # team_settings_home_path
    get :edit          # team_settings_edit_path（チーム編集）
    get :members       # team_settings_members_path（メンバー管理）
  end

  # teamのCRUD
  resources :teams

  # tasksのCRUD
  resources :tasks

end


