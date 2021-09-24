namespace :youtube do
  desc 'Queue settlement creation for qualifying balances'
  task :fetch_recent_videos_with_channel_id => :environment do |_task, args|
    Rails.logger.info 'START: Updating Youtube Infos.'
    YoutubeChannel.find_each do | youtube_channel |
      Rails.logger.info " - Updating..., title: #{youtube_channel.title}"
      YoutubeDataFetcher.new.fetch!(youtube_channel.channel_id)
    end
    Rails.logger.info 'END: Updating Youtube Infos.'
  end
end
