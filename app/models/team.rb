# app/models/team.rb
class Team < ApplicationRecord
  has_many :team_memberships, dependent: :destroy
  has_many :profiles, through: :team_memberships
  has_many :membership_requests, dependent: :destroy

  has_one_attached :avatar

  validates :name, presence: true, length: { maximum: 30 }
  validates :join_token, uniqueness: true, allow_nil: true

  before_create :set_join_token

  def display_initials
    base = name.presence || "?"
    base.split(/\s+/).map { |part| part[0] }.join[0, 2].upcase
  end

  attr_accessor :remove_avatar

  before_save :purge_avatar_if_needed

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
end
