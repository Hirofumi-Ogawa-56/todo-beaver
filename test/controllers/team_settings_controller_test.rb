require "test_helper"

class TeamSettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get team_settings_home_url
    assert_response :success
  end

  test "should get edit" do
    get team_settings_edit_url
    assert_response :success
  end

  test "should get members" do
    get team_settings_members_url
    assert_response :success
  end
end
