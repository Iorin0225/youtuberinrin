# frozen_string_literal: true

class YoutubeChannel < ApplicationRecord
  has_many :videos, class_name: 'YoutubeVideo', foreign_key: 'youtube_channels_id'

  def fetch!(recursive: true)
    YoutubeDataFetcher.new.fetch!(channel_id, recursive: recursive)
  end

  def self.install!(youtube_channel_id)
    if YoutubeChannel.where(channel_id: youtube_channel_id).exists?
      Rails.logger.info 'Already registered.'
      return
    end
    YoutubeDataFetcher.new.fetch_channel!(youtube_channel_id)
    Rails.logger.info 'Registered.'
  end
end
