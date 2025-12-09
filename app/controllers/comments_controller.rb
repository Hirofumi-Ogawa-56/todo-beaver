# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_profile!
  before_action :set_task
  before_action :set_comment, only: %i[edit update destroy]

  def create
    @comment = @task.comments.build(comment_params)
    @comment.author_profile = current_profile

    ActiveRecord::Base.transaction do
      @comment.save!
      apply_task_status_change
    end

    redirect_to task_path(@task), notice: "コメントを追加しました。"
  rescue ActiveRecord::RecordInvalid
    @comments = @task.comments.includes(:author_profile).order(:created_at)
    render "tasks/show", status: :unprocessable_entity
  end

  def edit
  end

  def update
    ActiveRecord::Base.transaction do
      @comment.update!(comment_params)
      apply_task_status_change
    end

    redirect_to task_path(@task), notice: "コメントを更新しました。"
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @comment.destroy
    redirect_to task_path(@task), notice: "コメントを削除しました。"
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def set_comment
    @comment = @task.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body, :pinned)
  end

  def apply_task_status_change
    new_status = params.dig(:comment, :task_status).presence
    return unless new_status

    @task.update!(status: new_status)
  end
end
