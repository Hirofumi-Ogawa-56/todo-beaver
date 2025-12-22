# db/migrate/xxxx_add_target_team_to_membership_requests.rb
class AddTargetTeamToMembershipRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :membership_requests, :target_team_id, :integer
    add_index :membership_requests, :target_team_id
  end
end
