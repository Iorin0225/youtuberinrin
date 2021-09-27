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
        Time.local(2021, 9, 27),
        '',
        [
          '目次の順序が崩れていたのを修正しました。',
        ]
      ],
      [
        Time.local(2021, 9, 24),
        '',
        [
          '日本時間04:00 AMに動画情報を自動更新するようにしました。',
          'アーカイブに残らない11:55:00以降の項目を隠しました。',
          'その他使いづらそうな点を修正しました。',
        ]
      ],
      [
        Time.local(2021, 9, 15),
        '',
        [
          '表示件数をデフォルト10件に削減しました。',
          'スマートフォンでも通信量が制限できますね。',
        ]
      ],
      [
        Time.local(2021, 8, 30),
        '',
        [
          'お知らせ表示する枠を追加しました。',
          '検索機能を公開しました。',
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
