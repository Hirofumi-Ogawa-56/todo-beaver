# app/controllers/users/confirmations_controller.rb
class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    @confirmation_token = params[:confirmation_token].to_s

    # まず生トークンで探す（digest保存じゃない場合に対応）
    self.resource = resource_class.find_by(confirmation_token: @confirmation_token)

    # 見つからなければ digest で探す（digest保存の場合に対応）
    if resource.nil?
      digested = Devise.token_generator.digest(resource_class, :confirmation_token, @confirmation_token)
      self.resource = resource_class.find_by(confirmation_token: digested)
    end

    if resource.nil?
      # ログイン済みだと new_user_session_path が root に戻されるので、ここはeditに返すのが親切
      redirect_to edit_user_registration_path, alert: "確認トークンが無効です（期限切れ/すでに確定済みの可能性があります）"
      return
    end

    render :confirm_change_email
  end

  def create
    token = params[:confirmation_token].to_s
    self.resource = resource_class.confirm_by_token(token)

    if resource.errors.empty?
      redirect_to edit_user_registration_path, notice: "メールアドレスを確定しました。"
    else
      redirect_to edit_user_registration_path, alert: resource.errors.full_messages.first
    end
  end
end
