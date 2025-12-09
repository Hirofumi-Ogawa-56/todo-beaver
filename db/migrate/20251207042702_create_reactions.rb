class CreateReactions < ActiveRecord::Migration[7.2]
  def change
    create_table :reactions do |t|
      t.references :comment, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true
      t.string :kind, null: false, default: "heart"

      t.timestamps
    end

    add_index :reactions, [ :comment_id, :profile_id, :kind ], unique: true
  end
end
