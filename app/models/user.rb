# app/models/user.rb

# Userクラスの定義
class User < ApplicationRecord
  # Userの機能を定義
  devise :database_authenticatable, # アドレス+パスワードでログインできる、パスワードのハッシュ化と認証処理
         :registerable, # ユーザーの新規登録・編集・削除を許可する機能
         :recoverable, # パスワードを忘れたときにリセットメールを送る機能
         :rememberable, # ログイン状態を保持する機能
         :validatable # バリテーションのデフォルトを適用する機能

  # Userの関連を定義
  has_many :profiles, dependent: :destroy # 一人のUserはたくさんのProfileを持てる
end
