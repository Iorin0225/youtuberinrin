# frozen_string_literal: true

class YoutubeComment < ApplicationRecord
  belongs_to :video, class_name: 'YoutubeVideo', foreign_key: 'youtube_videos_id'

  def markers
    markers = body.scan(%r{<a.*?>([^<]+)</a>([^<\r\n]+)})
    # markers = body.scan /<a.*?>[ 　]([^<]+)<\/a>([^<\r\n]+)/
    markers.map do |marker_array|
      marker = YoutubeVideoMarker.find_or_initialize_by(
        time: marker_array[0],
        label: CGI.unescapeHTML(marker_array[1].gsub(/　/, ' ').strip),
        youtube_videos_id: video.id
      )

      marker.seconds = marker.time_second
      marker.save!
    end
  end
end
