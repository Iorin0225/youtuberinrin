# frozen_string_literal: true

class TopController < ApplicationController
  def index
    @channel = YoutubeChannel.take
  end
end
