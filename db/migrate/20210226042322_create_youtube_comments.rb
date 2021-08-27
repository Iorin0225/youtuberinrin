class CreateYoutubeComments < ActiveRecord::Migration[6.0]
  def change
    create_table :youtube_comments do |t|
      t.string :comment_id
      t.text :body
      t.text :body_original
      t.references :youtube_videos

      t.timestamps
    end
  end
end
