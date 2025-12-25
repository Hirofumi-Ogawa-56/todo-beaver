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
        # message を呼ばず、attribute と type (エラーの種類) だけを出す
        details = req.errors.details.map { |attr, errors|
          "#{attr}: #{errors.map { |e| e[:error] }.join(', ')}"
        }.join(" / ")

        redirect_back fallback_location: edit_profile_path(current_profile),
                      alert: "申請に失敗しました（エラー詳細）: #{details}"
      end
    when "team_to_parent", "team_to_child"
      create_team_hierarchy_request(direction)
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

      # すでにメンバーだった場合でも role を更新できるようにする
      membership = TeamMembership.find_or_initialize_by(team: req.team, profile: current_profile)
      membership.role = role_value if req.admin? # 管理者招待なら上書き
      membership.save!

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
    when "team_to_parent", "team_to_child"
      approve_team_hierarchy_request(req)
    else
      redirect_back fallback_location: root_path, alert: "不正なリクエストです。"
    end
  end

  def destroy
    @membership_request = MembershipRequest.find(params[:id])

    # 権限チェック（招待を送った本人のチームの管理者か、など）
    if @membership_request.destroy
      redirect_back fallback_location: root_path, notice: "招待または申請を取り消しました。"
    else
      redirect_back fallback_location: root_path, alert: "取り消しに失敗しました。"
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
    admin_membership = team.team_memberships.find_by(profile: requester_profile, role: TeamMembership::ADMIN_ROLE)

    unless team.admin?(requester_profile) # ← ここで team.admin? を使っているので、上の1行はもう消しても大丈夫です！
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
      # エラー詳細を安全に取得する方式に変更
      details = membership_request.errors.details.map { |attr, errors|
        "#{attr}: #{errors.map { |e| e[:error] }.join(', ')}"
      }.join(" / ")

      redirect_back fallback_location: manage_team_path(team),
                    alert: "招待に失敗しました（詳細: #{details}）"
    end
  end

  # ★ チーム親子申請の作成
  def create_team_hierarchy_request(direction)
    from_team = Team.find(params[:team_id])
    to_team = Team.find(params[:target_team_id])

    # 権限チェック：操作しているチーム（from_team）の管理者であること
    unless from_team.admin?(current_profile)
      return redirect_back fallback_location: edit_team_path(from_team), alert: "権限がありません"
    end

    req = MembershipRequest.new(
      direction: direction,
      team: from_team,
      target_team: to_team,
      requester_profile: current_profile,
      status: :pending
    )

    if req.save
      redirect_back fallback_location: edit_team_path(from_team), notice: "申請・招待を送信しました。"
    else
      redirect_back fallback_location: edit_team_path(from_team), alert: "申請に失敗しました。"
    end
  end

  # ★ チーム親子申請の承認
  def approve_team_hierarchy_request(req)
    unless req.target_team.admin?(current_profile)
      return redirect_back fallback_location: root_path, alert: "承認権限がありません"
    end

    begin
      Team.transaction do
        if req.team_to_parent?
          # 下位チーム(team)側がすでに別の上位チームを持っていないか確認（任意）
          req.team.update!(parent: req.target_team)
        else
          # 下位チーム(target_team)側がすでに別の上位チームを持っていないか確認（任意）
          req.target_team.update!(parent: req.team)
        end
        req.update!(status: :approved)
      end
      redirect_back fallback_location: edit_team_path(req.target_team), notice: "組織構造を更新しました。"
    rescue ActiveRecord::RecordInvalid => e
      redirect_back fallback_location: edit_team_path(req.target_team), alert: "更新に失敗しました: #{e.record.errors.full_messages.join(', ')}"
    end
  end
end
