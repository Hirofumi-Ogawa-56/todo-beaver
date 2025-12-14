# app/controllers/reaction_controller.rb
class ReactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_profile!
  before_action :set_comment

  def create
    reaction = @comment.reactions.find_by(
      profile: current_profile,
      kind: "heart"
    )

    if reaction
      # すでに押している → 解除
      reaction.destroy
    else
      # まだ押していない → 付与
      @comment.reactions.create!(
        profile: current_profile,
        kind: "heart"
      )
    end

    redirect_to task_path(@comment.task)
  end

  private

  def set_comment
    @comment = Comment.find(params[:comment_id])
  end
end
