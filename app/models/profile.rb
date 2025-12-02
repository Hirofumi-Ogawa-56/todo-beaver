# app/models/profile.rb
# Profileクラスの定義
# app/models/profile.rb
class Profile < ApplicationRecord
  belongs_to :user

  validates :label, presence: true, length: { maximum: 25 }
  validates :theme, length: { maximum: 50 }, allow_blank: true
  validates :display_name, presence: true, length: { maximum: 30 }

  validates :join_token, uniqueness: true, allow_nil: true

  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships

  has_many :sent_membership_requests,
           class_name: "MembershipRequest",
           foreign_key: :requester_profile_id,
           dependent: :destroy

  has_many :received_membership_requests,
           class_name: "MembershipRequest",
           foreign_key: :target_profile_id,
           dependent: :destroy

  before_create :set_join_token

  private

  def set_join_token
    self.join_token ||= generate_unique_join_token
  end

  def generate_unique_join_token
    loop do
      token = SecureRandom.alphanumeric(8).upcase # 例: "A9B3ZK1Q"
      break token unless self.class.exists?(join_token: token)
    end
  end
end
