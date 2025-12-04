# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # モダンブラウザのみを許可する設定
  allow_browser versions: :modern

  # 全コントローラの処理の前に set_current_profile メソッドを実行する
  before_action :set_current_profile

  # current_profile メソッドを ビュー側（.erb）からも使えるようにする
  helper_method :current_profile

  private

  # 現在のユーザーの「選択中のProfile」を決めるメソッド
  def set_current_profile
    # ユーザーがログインしていなければ、何もせず終了
    return unless user_signed_in?

    # セッションに current_profile_id があれば、そのIDのプロフィールを探す
    if session[:current_profile_id].present?
      @current_profile = current_user.profiles.find_by(id: session[:current_profile_id])
    end

    # 見つからなかった場合は、ユーザーが持つ最初のProfileをデフォルトにする
    if @current_profile.nil?
      @current_profile = current_user.profiles.order(created_at: :asc).first
      # 見つかったら、そのIDをセッションに保存して次回以降も使う
      session[:current_profile_id] = @current_profile.id if @current_profile
    end
  end

  # 現在選択中のProfileを返す
  def current_profile
    @current_profile
  end

  # プロファイル切り替え用の共通メソッド
  # ProfilesController 以外からも呼びたくなったとき用
  def switch_profile(profile)
    return unless user_signed_in?
    return unless profile.user_id == current_user.id

    session[:current_profile_id] = profile.id
    @current_profile = profile
  end

  # プロフィール必須チェックを共通化
  def require_current_profile!
    return if current_profile

    redirect_to profiles_path,
                alert: "タスクを利用するにはプロフィールを選択してください。"
  end
end
