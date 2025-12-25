# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :chat_room
  belongs_to :author_profile, class_name: "Profile"
  belongs_to :parent_message, class_name: "Message", optional: true

  # チャットルームにメッセージが送信されたら、そのチャットルームを見ている全員の画面にブロードキャストする
  after_create_commit -> { broadcast_append_to chat_room, target: "main_messages" }

  # ポリモーフィック関連
  has_many :reactions, as: :reactable, dependent: :destroy
  has_many :heart_reactions,
           -> { where(kind: "heart") },
           as: :reactable,
           class_name: "Reaction"
  has_many :replies, class_name: "Message", foreign_key: "parent_message_id", dependent: :destroy

  validates :body, presence: true, length: { maximum: 2000 }

  def pinned?
    pinned
  end

  def edited?
    edited_at.present?
  end
end
