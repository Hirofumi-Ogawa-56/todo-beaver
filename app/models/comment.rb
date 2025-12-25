# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :task
  belongs_to :author_profile, class_name: "Profile"

  # 反映：comment_id ではなく reactable として扱う
  has_many :reactions, as: :reactable, dependent: :destroy
  has_many :heart_reactions,
           -> { where(kind: "heart") },
           as: :reactable,
           class_name: "Reaction"

  validates :body, presence: true, length: { maximum: 2000 }

  def pinned?
    pinned
  end
end
