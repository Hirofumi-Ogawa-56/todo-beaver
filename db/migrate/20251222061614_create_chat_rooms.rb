# db/migrate/xxxx_create_chat_rooms.rb
class CreateChatRooms < ActiveRecord::Migration[7.2]
  def change
    create_table :chat_rooms do |t|
      t.string :name
      t.text :description
      # ここを修正：参照先テーブルを profiles に指定
      t.references :creator_profile, null: false, foreign_key: { to_table: :profiles }

      t.timestamps
    end
  end
end
