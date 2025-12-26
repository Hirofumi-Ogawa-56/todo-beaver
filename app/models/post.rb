# app/models/post.rb
class Post < ApplicationRecord
  belongs_to :profile

  enum :post_type, { text: 0, image: 1, video: 2, work_link: 3 }

  # 修正：既存の Reaction モデルをポリモーフィックに使用
  has_many :reactions, as: :reactable, dependent: :destroy

  has_many :reposts, dependent: :destroy
  has_many :comments, class_name: "PostComment", dependent: :destroy

  validates :body, presence: true, length: { maximum: 10000 }

  # 自分がこの投稿にLike済みか判定するヘルパー（ビューで使用）
  def liked_by?(profile)
    reactions.where(profile: profile, kind: "heart").exists?
  end
end
