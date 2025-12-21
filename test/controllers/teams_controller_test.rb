# test/controllers/teams_controller_test.rb
require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
setup do
    @user, @profile = sign_in_with_profile
    @team = teams(:one)
    TeamMembership.create!(team: @team, profile: @profile, role: TeamMembership::ADMIN_ROLE)
  end

  test "should get index" do
    get teams_url
    assert_response :success
  end

  test "should get new" do
    get new_team_url
    assert_response :success
  end

  test "should show team" do
    get team_url(@team)
    assert_response :success
  end

  test "should get edit" do
    get edit_team_url(@team)
    assert_response :success
  end

  test "should get manage" do
    get manage_team_url(@team)
    assert_response :success
  end
end
