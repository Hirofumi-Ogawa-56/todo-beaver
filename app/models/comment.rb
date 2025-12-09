# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :task
  belongs_to :author_profile, class_name: "Profile"

  def pinned?
    pinned
  end

  has_many :reactions, dependent: :destroy
  has_many :heart_reactions,
           -> { where(kind: "heart") },
           class_name: "Reaction"

  validates :body, presence: true, length: { maximum: 2000 }
end
