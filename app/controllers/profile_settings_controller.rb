# app/controllers/profile_settings_controller.rb
class ProfileSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile

  def home
    # プロフィール設定ホーム
  end

  def edit
    # プロフィール編集
  end

  def theme
    # プロフィールカラー設定
    @themes = %w[default blue green red]
  end

  private

  def set_profile
    @profile = current_profile
  end
end