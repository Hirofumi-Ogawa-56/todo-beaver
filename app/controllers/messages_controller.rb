# app/controllers/message_controller.rb
class MessagesController < ApplicationController
  before_action :set_chat_room

  def create
    @message = @chat_room.messages.build(message_params)
    @message.author_profile = current_profile

    if @message.save
        # 親メッセージIDがあれば、スレッドの表示(show)へリダイレクトして右パネルを維持
        if @message.parent_message_id.present?
        redirect_to chat_room_message_path(@chat_room, @message.parent_message_id)
        else
        redirect_to chat_room_path(@chat_room)
        end
    else
        redirect_to chat_room_path(@chat_room), alert: "送信に失敗しました"
    end
  end

  def update
    @message = @chat_room.messages.find(params[:id])
    if @message.update(message_params)
      @message.update(edited_at: Time.current) # 編集時刻を記録
      redirect_to chat_room_path(@chat_room)
    end
  end

  def destroy
    @message = @chat_room.messages.find(params[:id])
    @message.destroy
    redirect_to chat_room_path(@chat_room), status: :see_other
  end

  def show
    @message = @chat_room.messages.find(params[:id])
    @replies = @message.replies.includes(:author_profile, :reactions).order(created_at: :asc)
    @new_reply = @message.replies.build(chat_room: @chat_room)

    render layout: false # サイドパネル（Turbo Frame）用なのでレイアウト不要
  end

  private

  def set_chat_room
    @chat_room = ChatRoom.find(params[:chat_room_id])
  end

  def message_params
    params.require(:message).permit(:body, :parent_message_id)
  end
end
