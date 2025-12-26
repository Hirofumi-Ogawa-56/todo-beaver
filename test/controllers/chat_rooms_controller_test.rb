# test/controllers/chat_rooms_controller_test.rb
require "test_helper"

class ChatRoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user, @profile = sign_in_with_profile
    @chat_room = chat_rooms(:one)
    @chat_room.chat_members.create!(profile: @profile)
  end

  test "should get index" do
    get chat_rooms_url # 正：chat_rooms_url
    assert_response :success
  end

  test "should get show" do
    get chat_room_url(@chat_room) # 正：chat_room_url(@chat_room)
    assert_response :success
  end

  test "should get new" do
    get new_chat_room_url # 正：new_chat_room_url
    assert_response :success
  end

  # chat_rooms_create_url というものは存在しないため、一覧へのPOSTとしてテストするか、一旦このテスト自体を削除します
  test "should create chat_room" do
    assert_difference("ChatRoom.count") do
      post chat_rooms_url, params: { chat_room: { name: "New Room" } }
    end
    assert_redirected_to chat_room_url(ChatRoom.last)
  end
end
