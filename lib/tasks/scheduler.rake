namespace :youtube do
  desc 'Queue settlement creation for qualifying balances'
  task :fetch_and_update_youtube_data => :environment do |_task, args|
    Rails.logger.info 'START: Updating Youtube Infos.'
    YoutubeChannel.find_each do | youtube_channel |
      Rails.logger.info " - Updating..., title: #{youtube_channel.title}"
      youtube_channel.fetch!
    end
    Rails.logger.info 'END: Updating Youtube Infos.'
  end
end
