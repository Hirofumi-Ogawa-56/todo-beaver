class AddDisplayNameToProfiles < ActiveRecord::Migration[7.2]
  def change
    add_column :profiles, :display_name, :string
  end
end
