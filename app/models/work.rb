# app/models/work.rb
class Work < ApplicationRecord
  belongs_to :profile
  belongs_to :team, optional: true

  enum :work_type, {
    document: "document",
    table: "table",
    book: "book",
    media: "media"
  }, prefix: true

  # 追加：表示用の日本語名を返すメソッド
  def work_type_human_name
    case work_type
    when "document" then "ドキュメント"
    when "table"    then "テーブル"
    when "book"     then "ブック"
    when "media"    then "メディア"
    else "ワークス"
    end
  end
end
