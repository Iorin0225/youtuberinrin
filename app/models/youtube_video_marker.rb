# frozen_string_literal: true

class YoutubeVideoMarker < ApplicationRecord
  VALID_MAX_SECONDS = (11.hour + 55.minutes) / 1.second

  belongs_to :video, class_name: 'YoutubeVideo', foreign_key: 'youtube_videos_id'
  scope :valid, -> { where('seconds <= ?', VALID_MAX_SECONDS) }

  def time_2nd
    case time.length
    when 7
      "0#{time}"
    when 6
      "00#{time}"
    when 5
      "00:#{time}"
    when 4
      "00:0#{time}"
    when 3
      "00:00#{time}"
    when 2
      "00:00:#{time}"
    when 1
      "00:00:0#{time}"
    else
      time
    end
  end

  def time_format
    time_2nd.to_time.strftime('%kh%Mm%Ss').strip
  rescue StandardError
    time_2nd
  end

  def time_second
    return seconds if seconds.present?

    (time_2nd.to_time - time_2nd.to_time.beginning_of_day).to_i
  rescue StandardError
    time_2nd
  end

  def self.generates_video_markers(update: false)
    ActiveRecord::Base.transaction do |_transaction|
      YoutubeComment.find_each(&:markers)
    end
  end
end
