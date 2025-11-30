# app/controllers/team_memberships_controller.rb
class TeamMembershipsController < ApplicationController
  before_action :authenticate_user!

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

  def destroy
    membership = TeamMembership.find(params[:id])
    team = membership.team
    membership.destroy

    redirect_back fallback_location: members_team_settings_path(team_id: team.id),
                  notice: "メンバーを削除しました"
  end
end
