# app/controllers/profile_settings_controller.rb
class ProfileSettingsController < ApplicationController
  before_action :authenticate_user!

  def home
    @profile = current_profile

    if @profile
      @incoming_team_invites =
        @profile.received_membership_requests
                .team_to_profile
                .pending
                .includes(:team, :requester_profile)
    else
      @incoming_team_invites = MembershipRequest.none
    end
  end

  def edit
    @profile = current_profile
    unless @profile
      redirect_to home_profile_settings_path, alert: "編集中のプロフィールが選択されていません。"
      return
    end

    @incoming_team_invites =
      @profile.received_membership_requests
              .team_to_profile
              .pending
              .includes(:team, :requester_profile)

    # ▼ 参加IDでチーム検索（GET）
    @team_invite_token = params[:team_invite_token].to_s.strip.upcase
    @invite_teams = @team_invite_token.present? ? Team.where(join_token: @team_invite_token) : Team.none
  end

  def theme; end
end
