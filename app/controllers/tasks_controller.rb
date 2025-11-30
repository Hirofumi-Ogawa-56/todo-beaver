# app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  before_action :authenticate_user!

  def index
    @tasks = []  # いったん空配列にしておく（ダミー）
  end
end
