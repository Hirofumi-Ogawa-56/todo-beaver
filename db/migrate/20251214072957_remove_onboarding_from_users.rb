class RemoveOnboardingFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :onboarding, :boolean
  end
end
