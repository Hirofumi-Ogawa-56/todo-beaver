# test/controllers/tasks_controller_test.rb
require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user, @profile = sign_in_with_profile
  end

  test "should get index" do
    get tasks_url
    assert_response :success
  end
end
