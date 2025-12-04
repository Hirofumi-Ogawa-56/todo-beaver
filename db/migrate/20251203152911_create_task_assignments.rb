# db/migrate/xxxx_create_task_assignments.rb
class CreateTaskAssignments < ActiveRecord::Migration[7.1]
  def change
    create_table :task_assignments do |t|
      t.references :task,    null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true

      t.timestamps
    end

    add_index :task_assignments, [ :task_id, :profile_id ], unique: true
  end
end
