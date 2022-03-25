# frozen_string_literal: true

module YoutubeChannelsHelper
  def tags_with_count_for_select(tags_with_count)
    @tags_with_count_for_select ||= tags_with_count.map do |tag, count|
      tag = tag.gsub('#', '')
      ["#{tag} (#{count})", tag]
    end
  end
end
