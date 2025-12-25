# app/models/post_comment.rb
class PostComment < ApplicationRecord
  belongs_to :post
  # author_profile_id を使って Profile モデルに紐づける
  belongs_to :author_profile, class_name: "Profile"

  validates :body, presence: true, length: { maximum: 2000 }
end
