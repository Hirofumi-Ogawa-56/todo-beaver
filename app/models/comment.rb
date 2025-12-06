class Comment < ApplicationRecord
  belongs_to :task
  belongs_to :author_profile, class_name: "Profile"

  validates :body, presence: true, length: { maximum: 2000 }
end
