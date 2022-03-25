# frozen_string_literal: true

class YoutubeChannel < ApplicationRecord
  has_many :videos, class_name: 'YoutubeVideo', foreign_key: 'youtube_channels_id'

  def tags
    return @tags if @tags.present?

    tmp_tags = []
    videos.select(:id, :tags).find_each do |video|
      new_tags = video.tags - tmp_tags
      tmp_tags += new_tags
    end
    tmp_tags.uniq!
    @tags = tmp_tags
  end

  def tags_with_count
    return @tags_with_count if @tags_with_count.present?
    tags_with_count = {}
    videos.select(:id, :tags).find_each do |video|
      video.tags.each do |tag|
        if tags_with_count[tag]&.integer?
          tags_with_count[tag] += 1
        else
          tags_with_count[tag] = 1
        end
      end
    end

    @tags_with_count = tags_with_count.sort_by(&:last).reverse!
  end

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
