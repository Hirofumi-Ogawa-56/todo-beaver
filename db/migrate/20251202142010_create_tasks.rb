# db/migrate/xxxx_create_tasks.rb
class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.references :owner_profile, null: false, foreign_key: { to_table: :profiles }
      t.references :assignee_profile, foreign_key: { to_table: :profiles }
      t.references :team, null: false, foreign_key: true

      t.string   :title, null: false
      t.text     :description
      t.datetime :due_at
      t.integer  :status, null: false, default: 0  # enum 用

      t.timestamps
    end
  end
end
