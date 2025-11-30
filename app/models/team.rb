# app/models/team.rb
class Team < ApplicationRecord
  has_many :team_memberships, dependent: :destroy
  has_many :profiles, through: :team_memberships

  validates :name, presence: true, length: { maximum: 30 }
end
