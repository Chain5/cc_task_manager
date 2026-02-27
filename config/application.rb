require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module TaskManager
  class Application < Rails::Application
    config.load_defaults 8.1

    # Rails 8: autoload lib but ignore assets/tasks
    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = "Rome"
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en]
  end
end
