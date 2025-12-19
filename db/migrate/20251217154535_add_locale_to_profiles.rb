class AddLocaleToProfiles < ActiveRecord::Migration[7.2]
  def change
    add_column :profiles, :locale, :string
  end
end
