# app/models/post_reaction.rb
class PostReaction < ApplicationRecord
  belongs_to :profile
  belongs_to :post
end
