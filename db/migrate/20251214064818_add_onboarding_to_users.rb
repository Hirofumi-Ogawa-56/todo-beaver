# db/migrate/xxxx_add_onboarding_to_users.rb
class AddOnboardingToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :onboarding, :boolean, null: false, default: false
  end
end
