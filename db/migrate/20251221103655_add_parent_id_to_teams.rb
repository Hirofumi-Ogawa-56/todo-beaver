# db/migrate/xxxx_add_parent_id_to_teams.rb
class AddParentIdToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :parent_id, :integer
    add_index :teams, :parent_id
    # 親の参照先も自分自身（teamsテーブル）であることを指定
    add_foreign_key :teams, :teams, column: :parent_id
  end
end
