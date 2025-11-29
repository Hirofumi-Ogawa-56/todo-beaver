class TeamSettingsController < ApplicationController
  before_action :authenticate_user!

  def home; 
  end

  def edit; 
    @teams = Team.order(created_at: :desc)
  end

  def members; 
  end
end