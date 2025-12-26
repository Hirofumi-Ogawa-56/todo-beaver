# db/migrate/xxxx_drop_post_reactions.rb
class DropPostReactions < ActiveRecord::Migration[7.2]
  def change
    # もしもの時のために、ロールバック（戻す処理）も書ける形式にします
    drop_table :post_reactions do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.integer :kind
      t.timestamps
    end
  end
end
