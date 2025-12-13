# app/models/membership_request.rb
class MembershipRequest < ApplicationRecord
  # 関連
  belongs_to :requester_profile, class_name: "Profile"
  belongs_to :target_profile, class_name: "Profile", optional: true
  belongs_to :team

  # 方向
  enum direction: {
    profile_to_team: 0, # プロフィール → チームに参加申請
    team_to_profile: 1  # チーム → プロフィールへ招待
  }

  # 状態
  enum status: {
    pending: 0,   # 申請中
    approved: 1,  # 承認済み
    rejected: 2,  # 却下
    canceled: 3   # 取り消し
  }

  # バリデーション
  validates :direction, presence: true
  validates :status, presence: true

  # 同じ内容の pending 申請を重複させない
  validates :requester_profile_id,
            uniqueness: {
              scope: [ :target_profile_id, :team_id, :direction ],
              conditions: -> { where(status: statuses[:pending]) },
              message: "同じ申請がすでに送信されており、承認待ちです。"
            }

  validate :target_presence

  private

  # direction に応じて、team or target_profile が必須
  def target_presence
    case direction&.to_sym
    when :profile_to_team
      errors.add(:team, "を指定してください") if team.nil?
    when :team_to_profile
      errors.add(:team, "を指定してください") if team.nil?
      errors.add(:target_profile, "を指定してください") if target_profile.nil?
    end
  end
end
