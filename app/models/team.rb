# app/models/team.rb
class Team < ApplicationRecord
  has_many :team_memberships, dependent: :destroy
  has_many :profiles, through: :team_memberships
  has_many :membership_requests, dependent: :destroy
  has_many :children, class_name: "Team", foreign_key: "parent_id", dependent: :destroy
  has_many :tasks, dependent: :nullify

  has_one_attached :avatar

  validates :name, presence: true, length: { maximum: 30 }
  validates :join_token, uniqueness: true, allow_nil: true
  validate :parent_cannot_be_self

  belongs_to :parent, class_name: "Team", optional: true

  before_create :set_join_token
  before_save :purge_avatar_if_needed

  def display_initials
    base = name.presence || "?"
    base.split(/\s+/).map { |part| part[0] }.join[0, 2].upcase
  end

  def full_hierarchical_name
    # ancestorsが親、祖父母...の順で並んでいると想定（親 > 子 の順にするためにreverse）
    names = ancestors.to_a.reverse.map(&:name)
    names << name
    names.join(" > ")
  end

  def ancestors
    list = []
    current = self.parent
    while current
      list << current
      current = current.parent
    end
    list
  end

  attr_accessor :remove_avatar

  def admin?(profile)
  # 1. 直接このチームの管理者かチェック
  return true if team_memberships.exists?(profile: profile, role: "admin")

  # 2. 親チームが存在する場合、親チームの管理者かチェック（再帰的にトップまで遡る）
  parent&.admin?(profile) || false
end

  private

  def set_join_token
    self.join_token ||= generate_unique_join_token
  end

  def generate_unique_join_token
    loop do
      token = SecureRandom.alphanumeric(8).upcase
      break token unless self.class.exists?(join_token: token)
    end
  end

  def purge_avatar_if_needed
    if ActiveModel::Type::Boolean.new.cast(remove_avatar)
      avatar.purge
    end
  end

  def parent_cannot_be_self
    if parent_id.present? && parent_id == id
      errors.add(:parent_id, "自分自身を親チームに設定することはできません")
    end
  end
end
