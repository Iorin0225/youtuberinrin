class CreateYoutubeVideos < ActiveRecord::Migration[6.0]
  def change
    create_table :youtube_videos do |t|
      t.string :video_id
      t.string :title
      t.text :description
      t.string :thumbnail_url
      t.text :tags

      t.datetime :published_at
      t.references :youtube_channels

      t.timestamps
    end
  end
end
