# frozen_string_literal: true

class YoutubeVideosController < ApplicationController
  def index
    @channel = YoutubeChannel.find_by(channel_id: params[:channel_id])
    @channel ||= YoutubeChannel.take
    @videos = @channel.videos
    @videos = process_search_query(search_query) if search_query.present?
    @videos = @videos.eager_load(:markers)
    @videos = @videos.order('youtube_videos.published_at DESC, youtube_video_markers.seconds ASC')
  end

  def show
    @videos = YoutubeVideo.where(video_id: params[:id])
    redirect_to :index if @videos.blank?
    @channel = @videos.take.channel

    render :index
  end

  private

  def process_search_query(query)
    like_query = "%#{query}%"
    @videos.where('youtube_videos.title LIKE ? OR youtube_videos.description LIKE ?', like_query, like_query)
  end

  def search_query
    params[:query]
  end
end
