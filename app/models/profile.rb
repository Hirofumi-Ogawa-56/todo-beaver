# app/models/profile.rb

#Profileクラスの定義
class Profile < ApplicationRecord
  belongs_to :user #Profileは必ず一人のUserに属する

  validates :name, presence: true, length: { maximum: 25 }
    #nameに関するバリテーション、空は不可・25文字まで
  validates :theme, length: { maximum: 50 }, allow_blank: true
    #themeに関するバリテーション、空でも可能・50文字まで
end
