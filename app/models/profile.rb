# app/models/profile.rb
class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :primary_team, class_name: "Team", optional: true

  validates :label, presence: true, length: { maximum: 25 }
  validates :display_name, presence: true, length: { maximum: 30 }

  validates :join_token, uniqueness: true, allow_nil: true

  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships

  has_many :task_assignments, dependent: :destroy
  has_many :assigned_tasks, through: :task_assignments, source: :task
  has_many :comments, foreign_key: :author_profile_id, dependent: :nullify
  has_many :reactions, dependent: :destroy
  has_many :works, dependent: :destroy

  has_many :sent_membership_requests,
           class_name: "MembershipRequest",
           foreign_key: :requester_profile_id,
           dependent: :destroy

  has_many :received_membership_requests,
           class_name: "MembershipRequest",
           foreign_key: :target_profile_id,
           dependent: :destroy

  has_many :chat_members, dependent: :destroy
  has_many :chat_rooms, through: :chat_members
  has_many :created_chat_rooms, class_name: "ChatRoom", foreign_key: "creator_profile_id"
  has_many :messages, foreign_key: "author_profile_id"

  has_one_attached :avatar

  attr_accessor :remove_avatar

  before_create :set_join_token
  before_save :purge_avatar_if_needed

  THEMES = %w[
  default
  slate
  indigo
  emerald
  rose
  amber
  ].freeze
  before_validation :set_default_theme
  validates :theme, inclusion: { in: THEMES }, allow_nil: true

  LOCALES = %w[ja en ja_en].freeze
  validates :locale, inclusion: { in: LOCALES }, allow_blank: true



  def display_initials
    base = display_name.presence || label.presence || "?"
    base.split(/\s+/).map { |part| part[0] }.join[0, 2].upcase
  end

  def organization_display_name
    # 1. 明示的に primary_team があればそれを使う
    # 2. なければ所属チームの最初を使う
    # 3. primary_team_id が nil（「表示しない」を選択）なら nil を返す

    # 判定のためにまず対象チームを特定
    target_team = primary_team || teams.first

    # primary_team_id カラムに -1 や 0 を入れる運用も可能ですが、
    # 既存の association (belongs_to :primary_team) を活かすため、
    # 「特定のID」ではなく「紐付けがあるかどうか」で判定するのがスマートです。

    target_team&.full_hierarchical_name
  end

  private

  def set_join_token
    self.join_token ||= generate_unique_join_token
  end

  def purge_avatar_if_needed
    if ActiveModel::Type::Boolean.new.cast(remove_avatar)
      avatar.purge
    end
  end

  def generate_unique_join_token
    loop do
      token = SecureRandom.alphanumeric(8).upcase # 例: "A9B3ZK1Q"
      break token unless self.class.exists?(join_token: token)
    end
  end

  def set_default_theme
    self.theme = "default" if theme.blank?
  end
end
