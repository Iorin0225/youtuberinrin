# frozen_string_literal: true

class YoutubeVideo < ApplicationRecord
  serialize :tags, JSON

  belongs_to :channel, class_name: 'YoutubeChannel', foreign_key: 'youtube_channels_id'
  has_many :comments, class_name: 'YoutubeComment', foreign_key: 'youtube_videos_id'
  has_many :markers, class_name: 'YoutubeVideoMarker', foreign_key: 'youtube_videos_id'

  def video_url
    "https://www.youtube.com/watch?v=#{video_id}"
  end

  def video_url_for_iframe
    "https://www.youtube.com/embed/#{video_id}"
  end

  def generate_markers
    comments.find_each(&:markers)
    markers
  end

  def self.update_description!(force: false, channel_id: nil)
    videos = force ? YoutubeVideo : YoutubeVideo.where('created_at > ?', 10.day.ago)
    videos = videos.where(youtube_channels_id: channel_id) if channel_id.present?
    fetcher = YoutubeDataFetcher.new
    ActiveRecord::Base.transaction do
      videos.where.not('description like ?', "%\n%").find_each do |video|
        video_hash = fetcher.request_video!(video.video_id)
        video.description = video_hash&.dig('snippet',
          'description')
        video.save! if video.description.present?
      rescue StandardError => _e
        Rails.logger.warning "Failed to updated: #{video.title}"
      end
    end
  end

  def self.update_tags!(force: false, created_at: 1.month.ago)
    videos = force ? YoutubeVideo : YoutubeVideo.where('tags is NULL')
    ActiveRecord::Base.transaction do
      videos.where('created_at > ?', created_at).find_each do |video|
        tags = video.description.scan(/[#＃][\w\p{Han}ぁ-ヶｦ-ﾟー 　']+/).map do |tag|
          tag.gsub(/　/, '').gsub(/＃/, '#').gsub(/# /, '#').strip
        end
        video.update!(tags: tags)
      rescue StandardError => _e
        Rails.logger.warning "Failed to updated: #{video.title}"
      end
    end
  end

  def self.format_thumbnail_url
    videos = []
    YoutubeVideo.find_each do |video|
      video.thumbnail_url = JSON.parse(video.thumbnail_url).first
      videos << video
    end
    videos
  end
end
