class Team < ApplicationRecord
  has_many :team_memberships, dependent: :destroy   # 後で作る想定
  has_many :profiles, through: :team_memberships    # 後で作る想定

  validates :name, presence: true, length: { maximum: 30 }
end