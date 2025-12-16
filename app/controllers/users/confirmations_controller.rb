# app/controllers/users/confirmations_controller.rb
class Users::ConfirmationsController < Devise::ConfirmationsController
  def create
    token = params[:confirmation_token].to_s

    # ✅ あなたの “メール変更確定” フロー
    if token.present?
      self.resource = resource_class.confirm_by_token(token)

      if resource.errors.empty?
        redirect_to edit_user_registration_path, notice: "メールアドレスを確定しました。"
      else
        redirect_to edit_user_registration_path, alert: resource.errors.full_messages.first
      end
      return
    end

    # ✅ Devise本来の “確認メール再送”
    super
  end
end
