# test/controllers/team_settings_controller_test.rb
require "test_helper"

class TeamSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user, @profile = sign_in_with_profile

    @team = Team.create!(name: "Team A")
    TeamMembership.create!(team: @team, profile: @profile, role: TeamMembership::ADMIN_ROLE)
  end

  test "should get home" do
    get home_team_settings_url
    assert_response :success
  end

  test "should get edit" do
    get edit_team_settings_url
    assert_response :success
  end

  test "should get members" do
    get members_team_settings_url
    assert_response :success
  end
end
