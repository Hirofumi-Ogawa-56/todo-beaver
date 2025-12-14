# app/models/task.rb
class Task < ApplicationRecord
  belongs_to :owner_profile,    class_name: "Profile"
  belongs_to :assignee_profile, class_name: "Profile", optional: true
  belongs_to :team, optional: true

  has_many :task_tags, dependent: :destroy
  has_many :tags, through: :task_tags
  has_many :task_assignments, dependent: :destroy
  has_many :assignees, through: :task_assignments, source: :profile
  has_many :comments, dependent: :destroy
  has_many :pinned_comments,
           -> { where(pinned: true).order(created_at: :asc) },
           class_name: "Comment"

  enum :status, { todo: 0, done: 1, in_progress: 2, archived: 3 }

  validates :title, presence: true, length: { maximum: 30 }
  validates :status, presence: true


  # フォーム用の「仮想」属性
  attr_accessor :due_date, :due_time, :tag_list

  # 検索スコープ
  scope :keyword_search, ->(query) do
    terms = query.to_s.strip.split(/\s+/)
    rel   = left_outer_joins(:tags).distinct

    terms.each do |term|
      next if term.blank?

      pattern = "%#{sanitize_sql_like(term)}%" # ← Task. は不要

      rel = rel.where(
        "tasks.title ILIKE :pattern OR tasks.description ILIKE :pattern OR tags.name ILIKE :pattern",
        pattern:
      )
    end

    rel
  end

  # フォーム表示用：既存タグ → カンマ区切り文字列
  def tag_list
    @tag_list || tags.pluck(:name).join(", ")
  end

  # カンマ区切り文字列から tags 関連を更新
  def update_tags_from_list!
    names =
      tag_list.to_s
              .split(/[,\n]/)
              .map { |n| n.strip }
              .reject(&:blank?)
              .uniq

    new_tags = names.map { |name| Tag.find_or_create_by!(name: name) }
    self.tags = new_tags
  end

  private

  def due_at_cannot_be_in_the_past
    return if due_at >= Time.current.beginning_of_day

    errors.add(:due_at, "は今日以降を指定してください")
  end
end
