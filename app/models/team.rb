# app/models/team.rb
class Team < ApplicationRecord
  has_many :team_memberships, dependent: :destroy
  has_many :profiles, through: :team_memberships

  validates :name, presence: true, length: { maximum: 30 }
  validates :join_token, uniqueness: true, allow_nil: true

  before_create :set_join_token

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
end
