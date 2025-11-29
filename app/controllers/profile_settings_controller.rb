# app/controllers/profile_settings_controller.rb
class ProfileSettingsController < ApplicationController
  before_action :authenticate_user!

  def home
  end

  def edit
    @profile = current_profile

    # current_profile が無い場合のガード
    unless @profile
      redirect_to profile_settings_home_path, alert: "編集中のプロフィールが選択されていません。"
    end
  end

  def theme
  end
end