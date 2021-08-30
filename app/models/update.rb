# frozen_string_literal: true

class Update
  attr_accessor :date, :title

  def date_to_human
    date.strftime('%Y.%m.%d')
  end

  def content=(value)
    @content = value.to_json
  end

  def content
    JSON.parse(@content)
  end

  def self.updates
    update_data_array = [
      [
        Time.local(2021, 8, 30),
        '',
        [
          '更新情報を表示する枠を追加しました。',
        ]
      ],
      [
        Time.local(2021, 8, 29),
        '',
        [
          '各動画の説明欄の表示を開始しました。',
          'Windowsでスクロールバーがダサいのを良い感じにしました。',
          'その他、UIを調整しました。'
        ]
      ]
    ]
    update_data_array.map do |update_data|
      update = Update.new
      update.date = update_data[0]
      update.title = update_data[1]
      update.content = update_data[2]
      update
    end
  end
end
