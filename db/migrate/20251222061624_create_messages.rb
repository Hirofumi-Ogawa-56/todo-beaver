# db/migrate/xxxx_create_messages.rb
class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages do |t|
      t.references :chat_room, null: false, foreign_key: true
      # ここを修正：参照先テーブルを profiles に指定
      t.references :author_profile, null: false, foreign_key: { to_table: :profiles }
      t.text :body
      t.boolean :pinned, default: false # default値を入れておくと扱いやすいです
      t.datetime :edited_at

      t.timestamps
    end
  end
end
