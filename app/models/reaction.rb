# app/models/reaction.rb
class Reaction < ApplicationRecord
  belongs_to :comment
  belongs_to :profile

  KINDS = %w[heart].freeze  # 将来ここに "smile", "thumbs_up" など足せる

  validates :kind,
            presence: true,
            inclusion: { in: KINDS }
end
