# test/controllers/profile_settings_controller_test.rb
require "test_helper"

class ProfileSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get home" do
    get home_profile_settings_url
    assert_response :success
  end

  test "should get edit" do
    get edit_profile_settings_url
    assert_response :success
  end

  test "should get theme" do
    get theme_profile_settings_url
    assert_response :success
  end
end

