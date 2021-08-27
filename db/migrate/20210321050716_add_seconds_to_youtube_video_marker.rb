class AddSecondsToYoutubeVideoMarker < ActiveRecord::Migration[6.0]
  def change
    add_column :youtube_video_markers, :seconds, :integer, after: :time
  end
end
