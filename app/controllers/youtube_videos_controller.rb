# frozen_string_literal: true

class YoutubeVideosController < ApplicationController

  LIMIT_DEFAULT = 50

  def index
    @channel = YoutubeChannel.find_by(channel_id: params[:channel_id])
    @channel ||= YoutubeChannel.take
    @videos = @channel&.videos || YoutubeVideo.all
    @videos = @videos.eager_load(:markers)
    if allow_no_marker?
      @videos = @videos.merge(YoutubeVideoMarker.valid_or_empty)
    else
      @videos = @videos.merge(YoutubeVideoMarker.valid)
    end

    process_search_query!
    process_limit!
    process_order!

    @tags_with_count = @channel.tags_with_count
    @limit = limit
    @marked = has_search_query?
    @highlight_words = highlight_words
  end

  def highlight_words
    return [] if fuzzy_search_query.blank?

    fuzzy_search_query.split(/\s+/).compact
  end

  def has_search_query?
    video_search_query.present? || marker_search_query.present? || fuzzy_search_query.present? || !default_limit?
  end

  def show
    @videos = YoutubeVideo.where(video_id: params[:id])
    redirect_to :index if @videos.blank?
    @channel = @videos.take.channel

    @videos = @videos.eager_load(:markers).merge(YoutubeVideoMarker.valid_or_empty)
    @videos = @videos.order('youtube_videos.published_at DESC, youtube_video_markers.seconds ASC')

    @tags_with_count = @channel.tags_with_count

    render :index
  end

  def update
    @videos = YoutubeVideo.where(video_id: params[:id])
    @videos.find_each do |video|
      fetcher = YoutubeDataFetcher.new
      fetcher.fetch_video!(video.video_id, update: true, is_generate_markers: true)
    end

    respond_to do |format|
      format.html { redirect_to action: :show, id: params[:id] }
      format.json { render json: { status: 'ok' } }
    end
  end

  private

  def process_limit!
    video_ids = if random?
      random_video_ids
    else
      ordered_video_ids
    end

    @videos.pluck('DISTINCT video_id').take(limit)
    @videos = @channel.videos.where(video_id: video_ids).eager_load(:markers)
  end

  def process_order!
    @videos = if random?
      @videos.order('youtube_video_markers.seconds ASC').shuffle
    else
      @videos.order('youtube_videos.published_at DESC, youtube_video_markers.seconds ASC')
    end
  end

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

    if fuzzy_search_query.present?
      fuzzy_query_words = fuzzy_search_query.split(/\s+/)
      fuzzy_query_words.each do |word|
        like_query = "%#{word}%"
        @videos = @videos.where(
          'youtube_videos.title LIKE ? OR youtube_videos.description LIKE ? OR youtube_video_markers.label LIKE ?',
          like_query, like_query, like_query
        )
      end
    end

    if tag_search_query.present?
      like_query = "%#{tag_search_query}%"
      @videos = @videos.where(
        'youtube_videos.title LIKE ? OR youtube_videos.description LIKE ?', like_query, like_query
      )
    end
  end

  def video_search_query
    params[:video_query]
  end

  def marker_search_query
    params[:marker_query]
  end

  def fuzzy_search_query
    params[:fuzzy_query]
  end

  def tag_search_query
    params[:tag_query]
  end

  def limit
    return LIMIT_DEFAULT unless params[:limit].present?

    params[:limit].to_i
  end

  def default_limit?
    limit == LIMIT_DEFAULT
  end

  def ordered_video_ids
    @videos.order('youtube_videos.published_at DESC, youtube_video_markers.seconds ASC').pluck('DISTINCT video_id').take(limit)
  end

  def random_video_ids
    @videos.pluck('DISTINCT video_id').sample(limit)
  end

  def random?
    @random ||= ActiveRecord::Type::Boolean.new.cast(params[:random])
  end

  def allow_no_marker?
    @allow_no_marker ||= if params[:allow_no_marker].present?
      ActiveRecord::Type::Boolean.new.cast(params[:allow_no_marker])
    else
      true
    end
  end
end
