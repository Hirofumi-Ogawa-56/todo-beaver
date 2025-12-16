# app/controllers/users/passwords_controller.rb
class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :authenticate_user!, only: %i[new create edit update]
  before_action :sign_out_if_signed_in, only: %i[edit update]

  def create
    email = resource_params[:email].to_s.downcase.strip
    deliver_emails = ENV.fetch("DELIVER_EMAILS", "false") == "true"

    is_new_demo_creation = false

    # 提出モードの場合、許可リストを作成
    unless deliver_emails
      allowed_demo_emails = []
      allowed_demo_emails << ENV.fetch("DEMO_EMAIL", "demo@example.com").to_s.downcase
      # 2つ目のデモメールが環境変数に設定されていれば追加
      if ENV["DEMO_EMAIL_2"].present?
        allowed_demo_emails << ENV["DEMO_EMAIL_2"].to_s.downcase
      end
      allowed_demo_emails.compact!

      # 許可リストに含まれていなければ、スパム登録を防ぐためにリダイレクト
      unless allowed_demo_emails.include?(email)
        return redirect_to new_user_session_path, alert: "提出モードでは指定されたデモメールのみ使用できます。"
      end
    end

    user = User.find_by(email: email)

    if user.nil?
      is_new_demo_creation = true
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

      # ★★★ 新しいユーザー作成時のプロフィール作成ロジックのみ実行 ★★★

      # 1. プロファイルを作成
      new_profile_label = email.split("@").first
      user.profiles.create!(
        display_name: new_profile_label.capitalize,
        label: new_profile_label,
        theme: "default"
      )

      # ★★★ チーム参加ロジックは削除 ★★★
    end

    if deliver_emails
      user.send_reset_password_instructions
      notice = "メールを送信しました。メールを確認し、リンクからパスワード設定（再設定）を完了してください。"
    else
      # ユーザーが今作成されたばかりの場合、その情報を通知
      if is_new_demo_creation
        notice = "テストユーザー**「#{email}」**を作成しました。パスワードは**「#{ENV.fetch("DEMO_PASSWORD", "password")}」**でログインしてください。"
      else
        # 既存のデモアカウントの場合
        notice = "デモアカウントを作成しました。画面上のデモID/パスワードでログインしてください。"
      end
    end

    redirect_to new_user_session_path, notice: notice
  end

  private

  def sign_out_if_signed_in
    sign_out(current_user) if user_signed_in?
  end
end
