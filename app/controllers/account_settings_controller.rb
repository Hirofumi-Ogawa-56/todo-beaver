# app/controllers/account_settings_controller.rb
class AccountSettingsController < ApplicationController
  before_action :authenticate_user!

  def send_change_email
    new_email = params[:email].to_s.strip

    if new_email.blank?
      redirect_back fallback_location: edit_user_registration_path, alert: "新しいメールアドレスを入力してください"
      return
    end

    if current_user.update(email: new_email)
      redirect_back fallback_location: edit_user_registration_path,
                    notice: "確認メールを送信しました。メール内リンクから手続きを進めてください。"
    else
      redirect_back fallback_location: edit_user_registration_path,
                    alert: current_user.errors.full_messages.first
    end
  end

  def send_password_reset
    current_user.send_reset_password_instructions
    redirect_back fallback_location: edit_user_registration_path,
                  notice: "パスワード変更用のメールを送信しました。"
  end
end
