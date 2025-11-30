# app/models/profile.rb
# Profileクラスの定義
class Profile < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { maximum: 25 }
  validates :theme, length: { maximum: 50 }, allow_blank: true

  # ★ 追加：表示名（他ユーザーに見せる用）
  validates :display_name, presence: true, length: { maximum: 30 }, allow_blank: true

  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships
end
