# app/controllers/reactions_controller.rb
class ReactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_profile!
  before_action :set_reactable

  def create
    @reaction = @reactable.reactions.find_or_initialize_by(profile: current_profile, kind: params[:kind])

    if @reaction.persisted?
      @reaction.destroy
    else
      @reaction.save
    end

    redirect_back fallback_location: root_path
  end

  private

  def set_reactable
    # /posts/1/reactions や /messages/5/reactions などのパスから
    # resource="posts", id="1" を抽出してモデルを特定する
    resource, id = request.path.split("/")[1, 2]
    @reactable = resource.singularize.classify.constantize.find(id)
  end
end
