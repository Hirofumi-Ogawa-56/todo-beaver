# app/models/membership_request.rb
class MembershipRequest < ApplicationRecord
  # 関連
  belongs_to :team
  belongs_to :target_team, class_name: "Team", optional: true
  belongs_to :requester_profile, class_name: "Profile", optional: true
  belongs_to :target_profile, class_name: "Profile", optional: true

  # 方向
  enum :direction, {
    profile_to_team: 0,
    team_to_profile: 1,
    team_to_parent: 2,
    team_to_child: 3   # ★これを追加
  }

  # 状態
  enum :status, { pending: 0, approved: 1, rejected: 2, canceled: 3 }

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
    when :team_to_parent, :team_to_child # ★チーム同士の申請でも相手が必要
      errors.add(:target_team, "を指定してください") if target_team.nil?
    end
  end
end
