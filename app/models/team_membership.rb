# app/models/team_membership.rb
class TeamMembership < ApplicationRecord
  belongs_to :team
  belongs_to :profile

  validates :profile_id, uniqueness: { scope: :team_id }

  ADMIN_ROLE = "admin"

  scope :admins, -> { where(role: ADMIN_ROLE) }

  def admin?
    role == ADMIN_ROLE
  end

  # 管理者がゼロになったら、全員を管理者にする
  after_destroy :ensure_at_least_one_admin
  after_update :ensure_at_least_one_admin, if: :saved_change_to_role?

  private

  def ensure_at_least_one_admin
    # まだこのチームに管理者がいれば何もしない
    return if team.team_memberships.admins.exists?

    # いなければ、このチームのメンバー全員を管理者に昇格
    team.team_memberships.update_all(role: ADMIN_ROLE)
  end
end
