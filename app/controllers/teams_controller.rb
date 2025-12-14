# app/controllers/teams_controller.rb
class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy]

  def index
    # いまは「自分が作ったチーム」という概念がないので、とりあえず全件
    # 後で TeamMembership や owner_profile ができたら絞り込む
    @teams = Team.order(created_at: :desc)
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

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(
      :name,
      :avatar,
      :remove_avatar
      )
  end
end
