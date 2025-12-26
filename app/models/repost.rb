# app/models/repost.rb
class Repost < ApplicationRecord
  belongs_to :profile
  belongs_to :post
end
