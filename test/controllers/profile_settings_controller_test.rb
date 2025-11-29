require "test_helper"

class ProfileSettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get profile_settings_home_url
    assert_response :success
  end

  test "should get edit" do
    get profile_settings_edit_url
    assert_response :success
  end

  test "should get theme" do
    get profile_settings_theme_url
    assert_response :success
  end
end
