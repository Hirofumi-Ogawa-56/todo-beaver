class RenameNameToLabelInProfiles < ActiveRecord::Migration[7.2]
  def change
    rename_column :profiles, :name, :label
  end
end
