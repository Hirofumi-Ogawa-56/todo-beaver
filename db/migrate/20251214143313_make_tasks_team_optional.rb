# db/migrate/xxxx_make_tasks_team_optional.rb
class MakeTasksTeamOptional < ActiveRecord::Migration[7.2]
  def change
    change_column_null :tasks, :team_id, true
  end
end
