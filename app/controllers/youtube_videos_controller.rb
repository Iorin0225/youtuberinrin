# frozen_string_literal: true

class YoutubeVideosController < ApplicationController
  def index
    @channel = YoutubeChannel.find_by(channel_id: params[:channel_id])
    @channel ||= YoutubeChannel.take
    @videos = @channel&.videos || YoutubeVideo.all
    @videos = @videos.eager_load(:markers).merge(YoutubeVideoMarker.valid)
    process_search_query!
    @videos = if random?
      @videos.where(video_id: random_video_ids).order('youtube_video_markers.seconds ASC')
    else
      @videos.order('youtube_videos.published_at DESC, youtube_video_markers.seconds ASC')
    end

    @limit = limit
    @marked = video_search_query.present? || marker_search_query.present? || limit.present?
  end

  def show
    @videos = YoutubeVideo.where(video_id: params[:id])
    redirect_to :index if @videos.blank?
    @channel = @videos.take.channel

    render :index
  end

  private

  def process_search_query!
    if video_search_query.present?
      like_query = "%#{video_search_query}%"
      @videos = @videos.where(
        'youtube_videos.title LIKE ? OR youtube_videos.description LIKE ?', like_query, like_query
      )
    end

    if marker_search_query.present?
      like_query = "%#{marker_search_query}%"
      @videos = @videos.where('youtube_video_markers.label LIKE ?', like_query)
    end
  end

  def video_search_query
    params[:video_query]
  end

  def marker_search_query
    params[:marker_query]
  end

  def limit
    return 10 unless params[:limit].present?

    params[:limit].to_i
  end

  def random_video_ids
    @channel.videos.joins(:markers).merge(YoutubeVideoMarker.valid).pluck(:video_id).uniq.sample(limit)
  end

  def random?
    @random ||= ActiveRecord::Type::Boolean.new.cast(params[:random])
  end
end
