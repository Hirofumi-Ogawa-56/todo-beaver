# app/controllers/teams_controller.rb
class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_profile!
  before_action :set_team, only: %i[show edit update destroy manage]

  def index
    # current_profile が存在する場合のみ、そのプロフィールが所属するチームを取得
    if current_profile
      @teams = current_profile.teams.distinct
    else
      @teams = []
    end
  end

  def show
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)

    if @team.save
      # 作成した人を自動的に管理者にする
      if current_profile
        TeamMembership.create!(
          team: @team,
          profile: current_profile,
          role: TeamMembership::ADMIN_ROLE
        )
      end
      redirect_to @team, notice: "チームを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: "チームを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_path, notice: "チームを削除しました"
  end

  # ★ 旧 team_settings#members を統合したアクション
  def manage
    # set_team により、この時点で @team は取得済みです

    @memberships = @team.team_memberships.includes(:profile)
    @members     = @memberships.map(&:profile)

    # 今のプロフィールがこのチームの管理者かどうか
    @current_membership = @memberships.find { |m| m.profile_id == current_profile.id }
    @can_manage_members = @current_membership&.admin?

    # プロフィール検索用（招待用トークン）
    @profile_invite_token = params[:profile_invite_token].to_s.strip.upcase
    if @profile_invite_token.present?
      @found_profile = Profile.where(join_token: @profile_invite_token)
                              .where.not(id: @members.map(&:id))
                              .first
    end

    # このチームに届いている参加申請（プロフィールからチームへ）
    @incoming_join_requests = @team.membership_requests
                                   .profile_to_team
                                   .pending
                                   .includes(:requester_profile)
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def require_current_profile!
    return if current_profile
    redirect_to profiles_path, alert: "プロフィールを選択してください。"
  end

  def team_params
    params.require(:team).permit(:name, :avatar, :remove_avatar)
  end
end
