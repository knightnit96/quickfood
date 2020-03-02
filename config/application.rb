require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Quickfood
  class Application < Rails::Application
    config.time_zone = Settings.time_zone
    config.load_defaults 5.1
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]
    config.i18n.available_locales = [:en, :vi]
    config.i18n.default_locale = :vi
    config.middleware.use I18n::JS::Middleware
    config.exceptions_app = self.routes
  end
end
