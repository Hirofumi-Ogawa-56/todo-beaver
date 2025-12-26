# app/models/reaction.rb
class Reaction < ApplicationRecord
  belongs_to :reactable, polymorphic: true
  belongs_to :profile

  KINDS = %w[heart].freeze

  validates :kind,
            presence: true,
            inclusion: { in: KINDS }
end
