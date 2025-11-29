class TeamSettingsController < ApplicationController
  before_action :authenticate_user!

  def home; end
  def edit; end
  def members; end
end