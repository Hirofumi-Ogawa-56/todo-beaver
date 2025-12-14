# test/test_helper.rb
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "devise/test/integration_helpers"

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)
  fixtures :all
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def sign_in_with_profile
    user = User.create!(
      email: "test-#{SecureRandom.hex(8)}@example.com",
      password: "password",
      password_confirmation: "password",
      confirmed_at: Time.current # confirmable 対策
    )

    sign_in user

    profile = user.profiles.create!(label: "work", display_name: "Work", theme: "default")
    post switch_profiles_path, params: { profile_id: profile.id }

    [ user, profile ]
  end
end
