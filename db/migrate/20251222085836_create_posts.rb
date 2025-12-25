class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.references :profile, null: false, foreign_key: true
      t.integer :post_type
      t.text :body
      t.jsonb :metadata

      t.timestamps
    end
  end
end
