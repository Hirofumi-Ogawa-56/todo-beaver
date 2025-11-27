# config/routes.rb

#ルーティング定義
Rails.application.routes.draw do
  # トップページ/にアクセスが来たら、HomeControllerのindexを呼び出す
  root "home#index"

  # deviseにUserモデル用の認証ルートをまとめて生成する
  devise_for :users

  # Profile用のルートをRESTfulにまとめて生成する
  resources :profiles

  # /up というパスに GET が来たら、Rails::HealthController の show アクションを呼ぶ。
  get "up" => "rails/health#show", as: :rails_health_check
end

