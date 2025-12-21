# app/controllers/membership_requests_controller.rb
class MembershipRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_membership_request, only: [ :approve ]

  def create
    direction = params[:direction]

    case direction
    when "team_to_profile"
      create_team_to_profile_request

    when "profile_to_team"
      team = Team.find(params[:team_id])

      # すでにメンバーなら申請不要
      if team.profiles.exists?(id: current_profile.id)
        redirect_back fallback_location: edit_profile_path(current_profile),
                      alert: "すでにこのチームのメンバーです"
        return
      end

      req = MembershipRequest.new(
        direction: "profile_to_team",
        team: team,
        requester_profile: current_profile,
        status: :pending,
        admin: params[:admin] == "1"
      )

      if req.save
        redirect_back fallback_location: edit_profile_path(current_profile),
                      notice: "参加申請を送信しました。"
      else
        redirect_back fallback_location: edit_profile_path(current_profile),
                      alert: req.errors.full_messages.first
      end

    else
      redirect_back fallback_location: root_path, alert: "不正なリクエストです。"
    end
  end

  def approve
    req = @membership_request

    case req.direction
    when "team_to_profile"
      unless req.pending? && req.target_profile_id == current_profile&.id
        redirect_back fallback_location: edit_profile_path(current_profile),
                      alert: "この招待は承認できません"
        return
      end

      TeamMembership.transaction do
        role_value = req.admin? ? TeamMembership::ADMIN_ROLE : nil

        TeamMembership.find_or_create_by!(team: req.team, profile: current_profile) do |m|
          m.role = role_value
        end

        if role_value.present?
          membership = TeamMembership.find_by!(team: req.team, profile: current_profile)
          membership.update!(role: TeamMembership::ADMIN_ROLE) unless membership.admin?
        end

        req.update!(status: :approved)
      end

      redirect_back fallback_location: edit_profile_path(current_profile),
                    notice: "チーム招待を承認しました。"

    when "profile_to_team"
      team    = req.team
      profile = req.requester_profile

      admin_membership =
        team.team_memberships.find_by(profile: current_profile, role: TeamMembership::ADMIN_ROLE)

      unless admin_membership
        redirect_back fallback_location: manage_team_path(team),
                      alert: "このチームの申請を承認する権限がありません"
        return
      end

      TeamMembership.transaction do
        TeamMembership.find_or_create_by!(team: team, profile: profile)
        req.update!(status: :approved)
      end

      redirect_back fallback_location: manage_team_path(team),
                    notice: "参加申請を承認しました。"

    else
      redirect_back fallback_location: root_path, alert: "不正なリクエストです。"
    end
  end

  private

  def set_membership_request
    @membership_request = MembershipRequest.find(params[:id])
  end

  def create_team_to_profile_request
    team = Team.find(params[:team_id])
    target_profile = Profile.find(params[:target_profile_id])

    requester_profile = current_profile
    unless requester_profile
      redirect_back fallback_location: manage_team_path(team),
                    alert: "現在のプロフィールが選択されていません"
      return
    end

    # 管理者だけ招待できる
    admin_membership =
      team.team_memberships.find_by(profile: requester_profile, role: TeamMembership::ADMIN_ROLE)

    unless admin_membership
      redirect_back fallback_location: manage_team_path(team),
                    alert: "このチームの招待を送る権限がありません"
      return
    end

    # すでにメンバーなら招待不要（任意だけど親切）
    if team.profiles.exists?(id: target_profile.id)
      redirect_back fallback_location: manage_team_path(team),
                    alert: "このプロフィールはすでにチームメンバーです"
      return
    end

    membership_request = MembershipRequest.new(
      requester_profile: requester_profile,
      target_profile: target_profile,
      team: team,
      direction: :team_to_profile,
      status: :pending,
      admin: params[:admin] == "1"
    )

    if membership_request.save
      redirect_back fallback_location: manage_team_path(team),
                    notice: "招待を送信しました"
    else
      redirect_back fallback_location: manage_team_path(team),
                    alert: membership_request.errors.full_messages.first
    end
  end
end
