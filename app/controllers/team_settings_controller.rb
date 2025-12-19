# app/controllers/team_settings_controller.rb
class TeamSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_profile!
  before_action :set_my_teams, only: [ :edit, :members ]

  def home
  end

  def edit
    # @teams は set_my_teams で
    # 「自分が所属しているチームだけ」に絞られています
  end

  def members
    @selected_team =
      if params[:team_id].present?
        @teams.find_by(id: params[:team_id])   # ← 自分のチームの中からだけ探す
      else
        @teams.first
      end

    if @selected_team
      @memberships = @selected_team.team_memberships.includes(:profile)
      @members      = @memberships.map(&:profile)

      # ✅ 今のプロフィールがこのチームでどんな membership を持っているか
      @current_membership =
        @memberships.find { |m| m.profile_id == current_profile.id }

      # ✅ この画面を見ている人が管理者かどうか
      @can_manage_members = @current_membership&.admin?

      # ▼ ここから：申請IDでプロフィール検索用 ▼
      @profile_invite_token = params[:profile_invite_token].to_s.strip.upcase

      if @profile_invite_token.present?
        # 検索結果を @found_profile に代入（ビューの if @found_profile と一致させる）
        @found_profile = Profile.where(join_token: @profile_invite_token)
                                .where.not(id: @members.map(&:id)) # すでにメンバーなら除外
                                .first
      end

      @incoming_join_requests = MembershipRequest
          .where(team: @selected_team, direction: "profile_to_team", status: "pending")
          .includes(:requester_profile)

    else
      @memberships        = []
      @members            = []
      @invite_token       = nil
      @invite_profiles    = Profile.none
      @current_membership = nil
      @can_manage_members = false
    end

    @incoming_join_requests =
      if @selected_team
        MembershipRequest
          .where(team: @selected_team, direction: "profile_to_team", status: "pending")
          .includes(:requester_profile)
      else
        MembershipRequest.none
      end
  end

  # プロフィールが選択されていないユーザーはチーム設定を見せない
  def require_current_profile!
    return if current_profile

    redirect_to profiles_path,
                alert: "チーム設定を利用するにはプロフィールを選択してください。"
  end

  # 「自分が所属しているチーム」だけを取得
  def set_my_teams
    @teams = current_profile.teams.order(:name)
  end
end
