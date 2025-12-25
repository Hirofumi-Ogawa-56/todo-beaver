# app/models/chat_room.rb
class ChatRoom < ApplicationRecord
  belongs_to :creator_profile, class_name: "Profile"
  has_many :chat_members, dependent: :destroy
  has_many :profiles, through: :chat_members
  has_many :messages, dependent: :destroy
  has_one_attached :avatar

  validates :name, length: { maximum: 100 } # 1:1の場合は空でも良い
end
