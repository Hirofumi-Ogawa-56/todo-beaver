# test/controllers/works_controller_test.rb
require "test_helper"

class WorksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user, @profile = sign_in_with_profile
    @work = works(:one)
    @work.update!(profile: @profile)
  end

  test "should get index" do
    get works_url # _index は不要
    assert_response :success
  end

  test "should get show" do
    get work_url(@work) # _show は不要、単数系にする
    assert_response :success
  end

  test "should get new" do
    get new_work_url # _new は不要、頭に new_
    assert_response :success
  end

  test "should get edit" do
    get edit_work_url(@work) # _edit は不要、頭に edit_
    assert_response :success
  end
end
