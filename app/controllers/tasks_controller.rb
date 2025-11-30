class TasksController < ApplicationController
  before_action :authenticate_user!

  def index
    @tasks = []  # いったん空配列にしておく（ダミー）
  end
end
