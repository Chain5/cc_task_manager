require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  # Cache store
  config.cache_store = :memory_store
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{2.days.to_i}" }

  # Mailer
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  # Deprecation notices
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  # Annotate rendered view with template name
  config.action_view.annotate_rendered_view_with_filenames = true

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  config.active_record.verbose_query_logs = true
end
