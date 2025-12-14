# app/controllers/users/passwords_controller.rb
class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :authenticate_user!, only: %i[new create edit update]
  before_action :sign_out_if_signed_in, only: %i[edit update]

  def create
    email = resource_params[:email].to_s.downcase.strip

    user = User.find_by(email: email)
    if user.nil?
      password = Devise.friendly_token.first(20)
      user = User.new(email: email, password: password, password_confirmation: password)

      unless user.save
        return redirect_to new_user_session_path, alert: user.errors.full_messages.first
      end
    end

    user.send_reset_password_instructions
    redirect_to new_user_session_path,
                notice: "メールを送信しました。メールを確認し、リンクからパスワード設定（再設定）を完了してください。"
  end

  private

  def sign_out_if_signed_in
    sign_out(current_user) if user_signed_in?
  end
end
