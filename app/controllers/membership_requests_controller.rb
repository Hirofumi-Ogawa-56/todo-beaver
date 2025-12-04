# app/controllers/membership_requests_controller.rb
class MembershipRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_membership_request, only: [ :approve ]

  def create
    case params[:direction]
    when "team_to_profile"
      create_team_to_profile_request
    # when "profile_to_team"
    #   プロフィール → チーム申請 を実装するときに使う予定
    else
      redirect_back fallback_location: root_path,
                    alert: "不正なリクエストです"
    end
  end

  def approve
    # 「この招待を承認してよい人か？」のチェック
    unless @membership_request.team_to_profile? &&
           @membership_request.pending? &&
           @membership_request.target_profile_id == current_profile&.id
      redirect_back fallback_location: home_profile_settings_path,
                    alert: "この招待は承認できません"
      return
    end

    MembershipRequest.transaction do
      # admin フラグに応じて role を決める
      role_value =
        if @membership_request.admin?
          TeamMembership::ADMIN_ROLE # 例: "admin"
        else
          nil
        end

      # チームにメンバーとして追加
      TeamMembership.create!(
        team: @membership_request.team,
        profile: current_profile,
        role: role_value
      )

      # 申請ステータスを approved に更新
      @membership_request.update!(status: :approved)
    end

    redirect_back fallback_location: home_profile_settings_path,
                  notice: "チーム招待を承認しました"
  end

  private

  def set_membership_request
    @membership_request = MembershipRequest.find(params[:id])
  end

  # チーム → プロフィール 招待の作成
  def create_team_to_profile_request
    team = Team.find(params[:team_id])
    target_profile = Profile.find(params[:target_profile_id])

    # 招待を発行した「側」のプロフィール（今の人の current_profile）を requester_profile として持たせておく
    requester_profile = current_profile
    unless requester_profile
      redirect_back fallback_location: members_team_settings_path(team_id: team.id),
                    alert: "現在のプロフィールが選択されていません"
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
      redirect_back fallback_location: members_team_settings_path(team_id: team.id),
                    notice: "招待を送信しました"
    else
      redirect_back fallback_location: members_team_settings_path(team_id: team.id),
                    alert: membership_request.errors.full_messages.to_sentence
    end
  end
end
