# db/migrate/xxxx_create_post_comments.rb
class CreatePostComments < ActiveRecord::Migration[7.2]
  def change
    create_table :post_comments do |t|
      t.references :post, null: false, foreign_key: true

      # ここを修正：to_table: :profiles を追加
      t.references :author_profile, null: false, foreign_key: { to_table: :profiles }

      t.text :body
      t.timestamps
    end
  end
end
