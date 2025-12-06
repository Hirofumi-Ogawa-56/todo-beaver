# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_profile!
  before_action :set_task
  before_action :set_comment, only: %i[edit update destroy]

  def create
    @comment = @task.comments.build(comment_params)
    @comment.author_profile = current_profile

    if @comment.save
      redirect_to task_path(@task), notice: "コメントを追加しました。"
    else
      # エラー時はタスク詳細をそのまま再表示
      @comments = @task.comments.includes(:author_profile).order(:created_at)
      render "tasks/show", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_to task_path(@task), notice: "コメントを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
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
    params.require(:comment).permit(:body)
  end
end
