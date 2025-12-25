# app/models/chat_member.rb
class ChatMember < ApplicationRecord
  belongs_to :chat_room
  belongs_to :profile

  validates :profile_id, uniqueness: { scope: :chat_room_id }
end
