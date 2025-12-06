# db/migrate/xxxx_create_commments.rb
class CreateComments < ActiveRecord::Migration[7.2]
  def change
    create_table :comments do |t|
      t.references :task, null: false, foreign_key: true
      t.references :author_profile, null: false, foreign_key: { to_table: :profiles }
      t.text :body, null: false

      t.timestamps
    end
  end
end
