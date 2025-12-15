# app/controllers/users/passwords_controller.rb
class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :authenticate_user!, only: %i[new create edit update]
  before_action :sign_out_if_signed_in, only: %i[edit update]

  def create
    email = resource_params[:email].to_s.downcase.strip
    deliver_emails = ENV.fetch("DELIVER_EMAILS", "false") == "true"

    # 提出モードではデモメールだけ許可（スパム登録防止）
    unless deliver_emails
      demo_email = ENV.fetch("DEMO_EMAIL", "demo@example.com").to_s.downcase
      return redirect_to new_user_session_path, alert: "提出モードではデモメールのみ使用できます。" unless email == demo_email
    end

    user = User.find_by(email: email)

    if user.nil?
      password =
        if deliver_emails
          Devise.friendly_token.first(20)
        else
          ENV.fetch("DEMO_PASSWORD", "password")
        end

      user = User.new(email: email, password: password, password_confirmation: password)

      # 提出モードは確認済みにしてログインできるようにする
      user.confirmed_at = Time.current unless deliver_emails

      unless user.save
        return redirect_to new_user_session_path, alert: user.errors.full_messages.first
      end
    end

    if deliver_emails
      user.send_reset_password_instructions
      notice = "メールを送信しました。メールを確認し、リンクからパスワード設定（再設定）を完了してください。"
    else
      notice = "デモアカウントを作成しました。画面上のデモID/パスワードでログインしてください。"
    end

    redirect_to new_user_session_path, notice: notice
  end

  private

  def sign_out_if_signed_in
    sign_out(current_user) if user_signed_in?
  end
end
