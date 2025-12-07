# db/migrate/xxxx_add_pinned_to_comments.rb
class AddPinnedToComments < ActiveRecord::Migration[7.1]
  def change
    add_column :comments, :pinned, :boolean, null: false, default: false
  end
end
