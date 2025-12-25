# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: %i[show edit update destroy settings]

  skip_before_action :verify_authenticity_token, only: :switch

  def index
    @profiles = current_user.profiles.order(created_at: :asc)
  end

  def show
  end

  def new
    @profile = current_user.profiles.build
  end

  def create
    @profile = current_user.profiles.build(profile_params)
    if @profile.save
      redirect_to @profile, notice: "プロフィールを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    prepare_membership_data
  end

  def update
    if @profile.update(profile_params)
      redirect_to @profile, notice: "プロフィールを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.profiles.count <= 1
      redirect_to profiles_path, alert: "最後のプロフィールは削除できません"
    else
      @profile.destroy
      redirect_to profiles_path, notice: "プロフィールを削除しました"
    end
  end

  def switch
    profile = current_user.profiles.find(params[:profile_id])
    session[:current_profile_id] = profile.id

    # Turboのキャッシュによる「古い情報の表示」を防ぐため、
    # redirect_back ではなく、パスを指定してトップレベルでリダイレクトします
    redirect_to root_path, status: :see_other, notice: "プロフィールを切り替えました"
  end

  def settings
    prepare_membership_data
  end

  private

  def set_profile
    @profile = current_user.profiles.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(
      :label,
      :display_name,
      :theme,
      :avatar,
      :remove_avatar,
      :locale,
      :primary_team_id
    )
  end

  def prepare_membership_data
    # 1. チーム検索ロジック
    @team_invite_token = params[:team_invite_token].to_s.strip.upcase
    @invite_teams = @team_invite_token.present? ? Team.where(join_token: @team_invite_token) : Team.none

    # 2. 自分(Profile)からチームへ送った「申請中」のリスト（申請取消用）
    @outgoing_requests = @profile.sent_membership_requests
                                 .profile_to_team
                                 .pending
                                 .includes(:team)

    # 3. チームから自分(Profile)へ届いた「招待」のリスト（承認・却下用）
    @incoming_team_invites = @profile.received_membership_requests
                                     .team_to_profile
                                     .pending
                                     .includes(:team, :requester_profile)
  end
end
