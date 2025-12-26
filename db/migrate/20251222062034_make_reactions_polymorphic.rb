# db/migrate/xxxx_make_reactions_polymorphic.rb
class MakeReactionsPolymorphic < ActiveRecord::Migration[7.2]
  def change
    remove_reference :reactions, :comment, foreign_key: true
    add_reference :reactions, :reactable, polymorphic: true, index: true
  end
end
