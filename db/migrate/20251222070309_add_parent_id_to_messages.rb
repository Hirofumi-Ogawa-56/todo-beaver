class AddParentIdToMessages < ActiveRecord::Migration[7.2]
  def change
    add_column :messages, :parent_message_id, :integer
    add_index :messages, :parent_message_id
  end
end
