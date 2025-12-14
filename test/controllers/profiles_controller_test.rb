# test/controllers/profiles_controller_test.rb
require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user, @profile = sign_in_with_profile
  end

  test "should get index" do
    get profiles_url
    assert_response :success
  end

  test "should get new" do
    get new_profile_url
    assert_response :success
  end

  test "should show profile" do
    get profile_url(@profile)
    assert_response :success
  end

  test "should get edit" do
    get edit_profile_url(@profile)
    assert_response :success
  end
end
