class AddAdminFlagToMembershipRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :membership_requests, :admin, :boolean, default: false, null: false
  end
end
