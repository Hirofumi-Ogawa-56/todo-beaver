# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: %i[show edit update destroy settings]

  skip_before_action :verify_authenticity_token, only: :switch

  def index
    @profiles = current_user.profiles.order(created_at: :asc)
  end

  def show
  end

  def new
    @profile = current_user.profiles.build
  end

  def create
    @profile = current_user.profiles.build(profile_params)
    if @profile.save
      redirect_to @profile, notice: "プロフィールを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      redirect_to @profile, notice: "プロフィールを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.profiles.count <= 1
      redirect_to profiles_path, alert: "最後のプロフィールは削除できません"
    else
      @profile.destroy
      redirect_to profiles_path, notice: "プロフィールを削除しました"
    end
  end

  def switch
    profile = current_user.profiles.find(params[:profile_id])
    session[:current_profile_id] = profile.id
    redirect_back fallback_location: profiles_path
  end

  def settings
    @incoming_team_invites = @profile.received_membership_requests
                                     .team_to_profile
                                     .pending
                                     .includes(:team, :requester_profile)


    @team_invite_token = params[:team_invite_token].to_s.strip.upcase
    @invite_teams = @team_invite_token.present? ? Team.where(join_token: @team_invite_token) : Team.none
  end

  private

  def set_profile
    @profile = current_user.profiles.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(
      :label,
      :display_name,
      :theme,
      :avatar,
      :remove_avatar,
      :locale
    )
  end
end
