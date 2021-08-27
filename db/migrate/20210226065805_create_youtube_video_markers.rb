class CreateYoutubeVideoMarkers < ActiveRecord::Migration[6.0]
  def change
    create_table :youtube_video_markers do |t|
      t.string :time
      t.string :label
      t.references :youtube_videos

      t.timestamps
    end
  end
end
