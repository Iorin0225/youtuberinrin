class CreateYoutubeChannels < ActiveRecord::Migration[6.0]
  def change
    create_table :youtube_channels do |t|
      t.string :channel_id
      t.string :title
      t.text :description
      t.string :thumbnail_url

      t.timestamps
    end
  end
end
