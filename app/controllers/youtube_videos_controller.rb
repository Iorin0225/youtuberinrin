# frozen_string_literal: true

class YoutubeVideosController < ApplicationController
  def index
    @channel = YoutubeChannel.find_by(channel_id: params[:channel_id])
    @channel ||= YoutubeChannel.take # UClO5iosel11ZtWTwYoYMa9w
    @videos = @channel.videos
  end

  def show
    @videos = YoutubeVideo.where(video_id: params[:id])
    redirect_to :index if @videos.blank?
    @channel = @videos.take.channel

    render :index
  end
end
