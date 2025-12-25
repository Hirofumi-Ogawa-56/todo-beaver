class CreateWorks < ActiveRecord::Migration[7.2]
  def change
    create_table :works do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.string :title
      t.text :body
      t.string :work_type
      t.integer :status

      t.timestamps
    end
  end
end
