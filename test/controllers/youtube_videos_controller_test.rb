require 'test_helper'

class YoutubeVideosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get youtube_videos_index_url
    assert_response :success
  end

end
