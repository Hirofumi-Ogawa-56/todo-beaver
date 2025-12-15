# config/environments/production.rb
require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false

  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.assets.compile = false

  config.active_storage.service = :local

  config.force_ssl = true

  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  config.log_tags = [ :request_id ]

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.action_mailer.perform_caching = false

  config.i18n.fallbacks = true

  config.active_support.report_deprecations = false

  config.active_record.dump_schema_after_migration = false

  config.active_record.attributes_for_inspect = [ :id ]

  config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_HOST", "todo-beaver.onrender.com"),
    protocol: "https"
  }

  # --- Submit mode switch (email delivery) ---
  deliver_emails = ENV.fetch("DELIVER_EMAILS", "false") == "true"

  config.action_mailer.perform_deliveries = deliver_emails
  config.action_mailer.raise_delivery_errors = deliver_emails

  config.public_file_server.enabled = true

  if deliver_emails
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: ENV.fetch("SMTP_ADDRESS"),
      port: ENV.fetch("SMTP_PORT", "587").to_i,
      domain: ENV.fetch("SMTP_DOMAIN", "todo-beaver.onrender.com"),
      user_name: ENV.fetch("SMTP_USERNAME"),
      password: ENV.fetch("SMTP_PASSWORD"),
      authentication: ENV.fetch("SMTP_AUTH", "plain").to_sym,
      enable_starttls_auto: ENV.fetch("SMTP_STARTTLS", "true") == "true"
    }
  else
    # Don't deliver emails in submit mode (prevents 500)
    config.action_mailer.delivery_method = :test
  end
end
