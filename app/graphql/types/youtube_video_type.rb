module Types
  class YoutubeVideoType < Types::BaseObject
    field :id, ID, null: false
    field :video_id, String, null: true
    field :title, String, null: true
    field :description, String, null: true
    field :thumbnail_url, String, null: true
    field :tags, String, null: true
    field :published_at, GraphQL::Types::ISO8601DateTime, null: true
    field :youtube_channels_id, Integer, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
