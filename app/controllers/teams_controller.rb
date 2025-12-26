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
    @team = Team.find(params[:id])

    unless @team.admin?(current_profile)
      redirect_to @team, alert: "編集権限がありません。"
      return
    end

    # --- [組織階層の設定用] 親子関係の検索ロジック ---
    if params[:parent_team_token].present?
      @found_parent_team = Team.find_by(join_token: params[:parent_team_token].upcase)
      if @found_parent_team == @team
        @found_parent_team = nil
        flash.now[:alert] = "自分自身を親チームに指定することはできません。"
      end
    end

    # 届いている親子関連申請
    @incoming_child_requests = MembershipRequest.where(
      target_team_id: @team.id,
      direction: [ :team_to_parent, :team_to_child ],
      status: :pending
    )

    # 送信済みの親子関連申請
    @outgoing_parent_request = MembershipRequest.where(
      team_id: @team.id,
      direction: [ :team_to_parent, :team_to_child ],
      status: :pending
    ).first
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

  def manage
    @team = Team.find(params[:id])
    @memberships = @team.team_memberships.includes(:profile)

    # 1. チームに参加したい！と個人から届いている申請
    @incoming_join_requests = @team.membership_requests.profile_to_team.pending

    # 2. チームから「入って！」と個人に送った招待（これを追加）
    @outgoing_invitations = @team.membership_requests.team_to_profile.pending

    # 招待検索ロジックなどはそのまま...
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
