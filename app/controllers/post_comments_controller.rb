# app/controllers/post_comments_controller.rb
class PostCommentsController < ApplicationController
  def index
    @post = Post.find(params[:post_id])
    @comments = @post.comments.includes(:author_profile).order(created_at: :asc)
    @new_comment = @post.comments.build
    render layout: false
  end

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(comment_params)
    @comment.author_profile = current_profile

    if @comment.save
      redirect_to post_comments_path(@post) # サイドパネル内を更新
    end
  end

  private

  def comment_params
    params.require(:post_comment).permit(:body)
  end
end
