# db/migrate/xxxx_create_team_memberships.rb
class CreateTeamMemberships < ActiveRecord::Migration[7.2]
  def change
    create_table :team_memberships do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :team,    null: false, foreign_key: true
      t.string :role

      t.timestamps
    end

    # 同じ profile が同じ team に二重登録されないようにする
    add_index :team_memberships, [ :profile_id, :team_id ], unique: true
  end
end
