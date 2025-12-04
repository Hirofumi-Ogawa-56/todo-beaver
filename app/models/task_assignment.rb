# app/models/task_assignment.rb
class TaskAssignment < ApplicationRecord
  belongs_to :task
  belongs_to :profile

  validates :profile_id, uniqueness: { scope: :task_id }
end
