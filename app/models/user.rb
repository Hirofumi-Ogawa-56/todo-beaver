# app/models/user.rb

# Userクラスの定義
class User < ApplicationRecord
  # Userの機能を定義
  devise :database_authenticatable,
        :registerable,
        :recoverable,
        :rememberable,
        :validatable,
        :confirmable

  # Userの関連を定義
  has_many :profiles, dependent: :destroy # 一人のUserはたくさんのProfileを持てる
end
