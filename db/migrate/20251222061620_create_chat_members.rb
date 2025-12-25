# db/migrate/xxxx_create_chat_members.rb
class CreateChatMembers < ActiveRecord::Migration[7.2]
  def change
    create_table :chat_members do |t|
      t.references :chat_room, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true
      t.string :room_display_name
      t.integer :unread_count, default: 0, null: false
      t.datetime :last_read_at

      t.timestamps
    end
  end
end
