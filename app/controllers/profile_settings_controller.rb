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

    # current_profile が無い場合のガード
    unless @profile
      redirect_to home_profile_settings_path, alert: "編集中のプロフィールが選択されていません。"
    end
  end

  def theme
  end
end
