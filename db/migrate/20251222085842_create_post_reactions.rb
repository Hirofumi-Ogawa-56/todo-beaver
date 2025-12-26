class CreatePostReactions < ActiveRecord::Migration[7.2]
  def change
    create_table :post_reactions do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.integer :kind

      t.timestamps
    end
  end
end
