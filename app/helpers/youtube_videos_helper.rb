# frozen_string_literal: true

module YoutubeVideosHelper
  def human_date(datetime)
    datetime.strftime('%Y/%m/%d')
  end

  def video_url_with_marker(video, marker)
    "#{video.video_url}&t=#{marker.time_second}s"
  end

  def video_url_with_marker_for_iframe(video, marker)
    "#{video.video_url_for_iframe}?autoplay=1&start=#{marker.time_second}"
  end
end
