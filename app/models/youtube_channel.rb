# frozen_string_literal: true

class YoutubeChannel < ApplicationRecord
  has_many :videos, class_name: 'YoutubeVideo', foreign_key: 'youtube_channels_id'
end
