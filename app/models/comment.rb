# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :task
  belongs_to :author_profile, class_name: "Profile"

  def pinned?
    pinned
  end

  validates :body, presence: true, length: { maximum: 2000 }
end
