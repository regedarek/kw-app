# frozen_string_literal: true

# FORCE test environment (Docker sets RAILS_ENV=development by default)
ENV['RAILS_ENV'] = 'test'

require 'spec_helper'
require_relative '../config/environment'

# Prevent running tests in production
abort("The Rails environment is running in production!") if Rails.env.production?

# ⚠️ CRITICAL: Verify Rails environment
# Due to Docker setting RAILS_ENV=development in Dockerfile, tests run in development by default.
# This is intentional - development.rb must include test hosts (www.example.com, example.com).
# If you see 403 "Blocked hosts" errors, check config/environments/development.rb includes test hosts.
unless Rails.env.development? || Rails.env.test?
  abort("Tests are running in #{Rails.env} environment! Expected development or test.")
end

if Rails.env.development?
  puts "⚠️  Tests are running in DEVELOPMENT environment (expected due to Docker RAILS_ENV=development)"
  puts "⚠️  Ensure config/environments/development.rb includes: config.hosts << 'www.example.com'"
end

require 'rspec/rails'

# Maintain test schema in sync with db/schema.rb
ActiveRecord::Migration.maintain_test_schema!

# Load all support files (devise, factory_bot, database_cleaner, shoulda_matchers, etc.)
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  # Use transactional fixtures (automatically rolls back after each test)
  # Disable if using DatabaseCleaner with truncation strategy
  config.use_transactional_fixtures = true

  # Verify test environment before running suite
  config.before(:suite) do
    unless Rails.env.test?
      abort("ERROR: Tests are running in #{Rails.env} environment! Must be 'test'.\n" \
            "Fix: Ensure ENV['RAILS_ENV'] = 'test' is set in rails_helper.rb")
    end
  end

  # Use expect syntax (not should)
  # Verify environment configuration before running tests
  config.before(:suite) do
    puts "\n" + "=" * 80
    puts "🧪 TEST SUITE STARTING"
    puts "=" * 80
    puts "Rails environment: #{Rails.env}"
    puts "ENV['RAILS_ENV']: #{ENV['RAILS_ENV']}"
    puts "config.hosts: #{Rails.application.config.hosts.inspect}"
    
    # Verify test hosts are allowed (critical for development environment)
    required_hosts = ['www.example.com', 'example.com']
    missing_hosts = required_hosts - Rails.application.config.hosts.map(&:to_s)
    
    if missing_hosts.any?
      puts "❌ ERROR: Required test hosts missing from config.hosts:"
      missing_hosts.each { |host| puts "   - #{host}" }
      puts "\nAdd to config/environments/#{Rails.env}.rb:"
      missing_hosts.each { |host| puts "  config.hosts << '#{host}'" }
      puts "\nThen restart: docker-compose restart app"
      abort("Test hosts not configured! See message above.")
    else
      puts "✅ Test hosts configured correctly"
    end
    
    puts "=" * 80 + "\n"
  end

  # Use expect syntax (not should)
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # Mock with RSpec
  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
    # REMOVED: allow_message_expectations_on_nil (discouraged, hides bugs)
  end

  # FactoryBot methods available without prefix (create, build, build_stubbed)
  config.include FactoryBot::Syntax::Methods

  # Automatically infer spec type from file location
  # spec/models/user_spec.rb → type: :model
  # spec/requests/users_spec.rb → type: :request
  config.infer_spec_type_from_file_location!

  # Filter out Rails internal stack traces from test output
  config.filter_rails_from_backtrace!

  # Randomize test order (helps catch test interdependencies)
  config.order = :random
  Kernel.srand config.seed
end