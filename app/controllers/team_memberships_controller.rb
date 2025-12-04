# app/controllers/team_memberships_controller.rb
class TeamMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team_membership, only: [ :destroy, :update ]
  before_action :require_team_admin!, only: [ :destroy, :update ]

  def create
    team    = Team.find(params[:team_id])
    profile = Profile.find(params[:profile_id])

    membership = TeamMembership.new(
      team: team,
      profile: profile,
      role: params[:role].presence # 入力なければ nil のまま
    )

    if membership.save
      redirect_back fallback_location: members_team_settings_path(team_id: team.id),
                    notice: "メンバーを追加しました"
    else
      redirect_back fallback_location: members_team_settings_path(team_id: team.id),
                    alert: "メンバーを追加できませんでした"
    end
  end

  # ★ 追加：役割変更
  def update
    team = @team_membership.team

    # selectから来る値（"admin" or ""）を受け取る
    new_role = params.require(:team_membership)[:role].presence

    if @team_membership.update(role: new_role)
      redirect_back fallback_location: members_team_settings_path(team_id: team.id),
                    notice: "メンバーの役割を更新しました"
    else
      redirect_back fallback_location: members_team_settings_path(team_id: team.id),
                    alert:  "役割を更新できませんでした"
    end
  end

  def destroy
    team = @team_membership.team
    @team_membership.destroy

    redirect_back fallback_location: members_team_settings_path(team_id: team.id),
                  notice: "メンバーを削除しました"
  end

  private

  def set_team_membership
    @team_membership = TeamMembership.find(params[:id])
  end

  # このチームの「管理者」だけが destroy / update できる
  def require_team_admin!
    team = @team_membership.team

    admin_membership = team.team_memberships.find_by(
      profile: current_profile,
      role: TeamMembership::ADMIN_ROLE
    )

    return if admin_membership

    redirect_to root_path,
                alert: "このチームのメンバー管理を行う権限がありません"
  end
end
