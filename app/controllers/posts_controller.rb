# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def index
    # ページネーションなどは後ほどとして、まずは最新順に取得
    @posts = Post.includes(:profile, :comments, :reactions, :reposts).order(created_at: :desc)
  end

  def create
    @post = Post.new(post_params)
    @post.profile = current_profile
    @post.post_type = :text # デフォルトはテキスト

    if @post.save
      redirect_to posts_path, notice: "投稿しました"
    else
      @posts = Post.all.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:body)
  end
end
