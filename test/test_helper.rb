# test/test_helper.rb
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "devise/test/integration_helpers"

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)
  fixtures :all

  include Devise::Test::IntegrationHelpers
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def sign_in_with_profile
    # User.create! の引数に profiles_attributes を含めることで
    # バリデーションエラーを回避し、一気に作成します
    user = User.create!(
      email: "test-#{SecureRandom.hex(8)}@example.com",
      password: "password",
      password_confirmation: "password",
      confirmed_at: Time.current,
      profiles_attributes: [
        { label: "work", display_name: "Work User", theme: "default" }
      ]
    )

    profile = user.profiles.first

    # 1. ログイン
    sign_in user

    # 2. プロフィールをセッションにセットする（切り替え処理をシミュレート）
    # routes.rb にある実際のパスに合わせて調整してください
    post switch_profiles_path, params: { profile_id: profile.id }

    [ user, profile ]
  end
end
