module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :youtube_videos,
          Types::YoutubeVideoType,
          null: false,
          description: 'Stored youtube videos' do
            argument :channel_id, Int, required: true
          end
    def youtube_videos(channel_id:)
      YoutubeVideo.where(channel_id: channel_id).all
    end
  end
end
