# db/migrate/xxxx_change_team_id_null_on_works.rb
class ChangeTeamIdNullOnWorks < ActiveRecord::Migration[7.1]
  def change
    # false (Not Null) から true (NULLを許可) に変更
    change_column_null :works, :team_id, true
  end
end
