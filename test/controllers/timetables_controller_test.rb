require "test_helper"

class TimetablesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get timetables_index_url
    assert_response :success
  end
end
