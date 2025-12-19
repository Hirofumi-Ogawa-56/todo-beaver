# config/application.rb
require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module TodoBeaver
  class Application < Rails::Application
    config.load_defaults 7.2

    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = "Tokyo"
    config.active_record.default_timezone = :local

    config.i18n.default_locale = :ja_en
    config.i18n.available_locales = [ :ja, :en, :ja_en ]
  end
end
