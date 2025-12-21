# app/models/profile.rb
class Profile < ApplicationRecord
  belongs_to :user

  validates :label, presence: true, length: { maximum: 25 }
  validates :display_name, presence: true, length: { maximum: 30 }

  validates :join_token, uniqueness: true, allow_nil: true

  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships

  has_many :task_assignments, dependent: :destroy
  has_many :assigned_tasks, through: :task_assignments, source: :task
  has_many :comments, foreign_key: :author_profile_id, dependent: :nullify
  has_many :reactions, dependent: :destroy

  has_many :sent_membership_requests,
           class_name: "MembershipRequest",
           foreign_key: :requester_profile_id,
           dependent: :destroy

  has_many :received_membership_requests,
           class_name: "MembershipRequest",
           foreign_key: :target_profile_id,
           dependent: :destroy

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
