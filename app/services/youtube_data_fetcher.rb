# frozen_string_literal: true

class YoutubeDataFetcher
  GOOGLE_API_ENDPOINT  = 'https://www.googleapis.com'
  GOOGLE_API_KEY       = ENV['YOUTUBERINRIN_GOOGLE_API_KEY']
  YOUTUBE_PATH         = '/youtube/v3'
  CHANNELS_PATH        = "#{YOUTUBE_PATH}/channels"
  VIDEOS_PATH          = "#{YOUTUBE_PATH}/videos"
  SEARCH_PATH          = "#{YOUTUBE_PATH}/search"
  COMMENT_THREADS_PATH = "#{YOUTUBE_PATH}/commentThreads"
  COMMENTS_PATH        = "#{YOUTUBE_PATH}/comments"

  def initialize; end

  def fetch!(channel_id, update: false, recursive: true)
    channel_hash = request_channel!(channel_id)
    channel = YoutubeChannel.find_or_initialize_by(
      channel_id: channel_hash['id']
    )

    channel.title = channel_hash['snippet']['title']
    channel.description = channel_hash['snippet']['description']
    channel.thumbnail_url = channel_hash['snippet']['thumbnails']['high']['url']
    channel.save!

    video_hashes = request_search!(channel_id, recursive: recursive)
    video_hashes.each do |video_hash|
      next if video_hash['id']['videoId'].nil?

      video = YoutubeVideo.find_or_initialize_by(
        video_id: video_hash['id']['videoId']
      )
      next if video.persisted? && update == false

      video.title = video_hash['snippet']['title']
      video.description = video_hash['snippet']['description']
      video.thumbnail_url = video_hash['snippet']['thumbnails']['high']['url']
      video.published_at = video_hash['snippet']['publishedAt']
      video.youtube_channels_id = channel.id
      video.save!

      fetch_comments!(video.video_id, is_generate_markers: true)
    end

    YoutubeVideo.update_description!
  end

  def fetch_channel!(channel_id)
    channel_hash = request_channel!(channel_id)
    channel = YoutubeChannel.find_or_initialize_by(
      channel_id: channel_hash['id']
    )

    channel.title = channel_hash['snippet']['title']
    channel.description = channel_hash['snippet']['description']
    channel.thumbnail_url = channel_hash['snippet']['thumbnails']['high']['url']
    channel.save!
  end

  def fetch_videos!(channel_id, query: nil, with_comments: true, recursive: true)
    channel = YoutubeChannel.find_by!(channel_id: channel_id)

    video_hashes = request_search!(channel_id, query: query, recursive: recursive)
    video_hashes.each do |video_hash|
      next if video_hash['id']['videoId'].nil?

      video = YoutubeVideo.find_or_initialize_by(
        video_id: video_hash['id']['videoId']
      )

      video.title               = video_hash['snippet']['title']
      video.description         = video_hash['snippet']['description']
      video.thumbnail_url       = video_hash['snippet']['thumbnails']['high']['url']
      video.published_at        = video_hash['snippet']['publishedAt']
      video.youtube_channels_id = channel.id
      video.save!

      fetch_comments!(video.video_id, is_generate_markers: true) if with_comments
    end
  end

  # private

  def fetch_video!(video_id, update: false, is_generate_markers: false)
    video = YoutubeVideo.find_or_initialize_by(
      video_id: video_id
    )
    return false if video.persisted? && update == false

    video_hash = request_video!(video_id)
    channel = YoutubeChannel.find_or_create_by(
      channel_id: video_hash['snippet']['channelId']
    )

    video.title               = video_hash['snippet']['title']
    video.description         = video_hash['snippet']['description']
    video.thumbnail_url       = video_hash['snippet']['thumbnails']['high']['url']
    video.published_at        = video_hash['snippet']['publishedAt']
    video.youtube_channels_id = channel.id
    video.save!

    unless video_hash['snippet']['liveBroadcastContent'] == 'upcoming'
      fetch_comments!(video.video_id, update: update, is_generate_markers: is_generate_markers)
    end
  end

  def fetch_comments_with_channel_id!(channel_id, update: false, is_generate_markers: false)
    channel = YoutubeChannel.find_by!(channel_id: channel_id)

    channel.videos.find_each do |video|
      fetch_comments!(video.video_id, update: update, is_generate_markers: is_generate_markers)
    end
  end

  def fetch_comments!(video_id, update: false, is_generate_markers: false)
    video = YoutubeVideo.find_by(video_id: video_id)
    return false if video.blank?
    return false if video.comments.present? && update == false

    comment_hashes = request_comment_threads!(video.video_id)
    comment_hashes.each do |comment_hash|
      YoutubeComment.find_or_create_by!(
        youtube_videos_id: video.id,
        body: comment_hash['snippet']['topLevelComment']['snippet']['textDisplay'],
        body_original: comment_hash['snippet']['topLevelComment']['snippet']['textOriginal']
      )
    end

    ActiveRecord::Base.transaction do
      video.generate_markers if is_generate_markers
    end

    comment_hashes
  end

  def request_channel!(channel_id)
    params = {
      key: GOOGLE_API_KEY,
      id: channel_id,
      part: 'snippet'
    }
    response = send_request(CHANNELS_PATH, :get, params, nil)
    raise error_message(response) unless response.success?

    JSON.parse(response.body)['items'].first
  end

  def request_video!(video_id)
    params = {
      key: GOOGLE_API_KEY,
      id: video_id,
      part: 'snippet'
    }
    response = send_request(VIDEOS_PATH, :get, params, nil)
    raise error_message(response) unless response.success?

    JSON.parse(response.body)['items'].first
  end

  def request_search!(channel_id, page_token = nil, query: nil, recursive: true)
    params = {
      key: GOOGLE_API_KEY,
      channelId: channel_id,
      q: query,
      part: 'snippet,id',
      type: 'video',
      order: 'date',
      maxResults: 50,
      pageToken: page_token
    }
    response = send_request(SEARCH_PATH, :get, params, nil)
    raise error_message(response) unless response.success?

    response_hash = JSON.parse(response.body)
    # response_hash['items']
    items = response_hash['items']
    return [] if items.empty?

    if recursive && response_hash.key?('nextPageToken')
      items | request_search!(channel_id, response_hash['nextPageToken'], query: query, recursive: recursive)
    else
      items
    end
  end

  def request_comment_threads!(video_id, page_token = nil)
    params = {
      key: GOOGLE_API_KEY,
      videoId: video_id,
      part: 'snippet',
      pageToken: page_token
    }
    response = send_request(COMMENT_THREADS_PATH, :get, params, nil)
    raise error_message(response) unless response.success?

    response_hash = JSON.parse(response.body)
    items = response_hash['items']

    if response_hash.key?('nextPageToken')
      items | request_comment_threads!(video_id, response_hash['nextPageToken'])
    else
      items
    end
  end

  def connection
    Faraday.new(url: GOOGLE_API_ENDPOINT, ssl: nil) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger, Rails.logger
      faraday.adapter  Faraday.default_adapter
    end
  end

  def send_request(path, method, params, body)
    connection.send(method) do |req|
      req.url path
      req.headers['Content-Type'] = 'application/json'
      req.params = params if params.present?
      req.body = body if body.present?
      req.options.timeout = 30
      req.options.open_timeout = 30
    end
  end

  def error_message(response)
    return nil if response.success?

    body = JSON.parse(response.body)
    body['error']['message']
  end
end
