require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module KwApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    #

    # Configure lib/ directory for autoloading (Rails 7.0 manual setup)
    # Note: Rails 7.1+ can use config.autoload_lib(ignore: %w[...]) instead
    lib = root.join("lib")
    config.autoload_paths += [lib]
    config.eager_load_paths += [lib]
    
    # Ignore non-code subdirectories in lib/
    Rails.autoloaders.main.ignore(
      lib.join("tasks"),
      lib.join("seeding"),
      lib.join("playwright"),
      lib.join("locales")
    )
  end
end
