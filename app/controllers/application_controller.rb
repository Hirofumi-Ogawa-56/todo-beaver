# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :set_current_profile
  helper_method :current_profile

  private

  def set_current_profile
    return unless user_signed_in?

    if session[:current_profile_id].present?
      @current_profile = current_user.profiles.find_by(id: session[:current_profile_id])
    end

    if @current_profile.nil?
      @current_profile = current_user.profiles.order(created_at: :asc).first
      session[:current_profile_id] = @current_profile.id if @current_profile
    end
  end

  def current_profile
    @current_profile
  end

  def switch_profile(profile)
    return unless user_signed_in?
    return unless profile.user_id == current_user.id

    session[:current_profile_id] = profile.id
    @current_profile = profile
  end

  def require_current_profile!
    return if current_profile

    redirect_to profiles_path,
                alert: "タスクを利用するにはプロフィールを選択してください。"
  end
end
