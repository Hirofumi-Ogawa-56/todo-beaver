class AddJoinTokenToProfilesAndTeams < ActiveRecord::Migration[7.2]
  def change
    add_column :profiles, :join_token, :string
    add_index  :profiles, :join_token, unique: true

    add_column :teams, :join_token, :string
    add_index  :teams, :join_token, unique: true
  end
end
