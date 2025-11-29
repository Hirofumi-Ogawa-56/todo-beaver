# app/controllers/team_setting_controller.rb
class TeamSettingsController < ApplicationController
  before_action :authenticate_user!

  def home; 
  end

  def edit; 
    @teams = Team.order(created_at: :desc)
  end

  def members; 
    # とりあえず全チームを選択肢に出す（あとで「自分のチームだけ」に絞ってもOK）
    @teams = Team.order(:name)

    # 選択中のチーム（パラメータがなければ先頭）
    selected_id = params[:team_id] || @teams.first&.id
    @selected_team = selected_id.present? ? Team.find(selected_id) : nil

    if @selected_team
      @memberships = @selected_team.team_memberships.includes(:profile)
      @members = @memberships.map(&:profile)

      # 追加候補：現在のユーザーのプロフィールから、まだこのチームに入ってないもの
      @candidate_profiles =
        Profile.where.not(id: @members.map(&:id))
    else
      @memberships = []
      @members = []
      @candidate_profiles = []
    end
  end
end