# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'spec_helper'
require_relative '../config/environment'

# Prevent running tests in production
abort("The Rails environment is running in production!") if Rails.env.production?

require 'rspec/rails'

# Maintain test schema in sync with db/schema.rb
ActiveRecord::Migration.maintain_test_schema!

# Load all support files (devise, factory_bot, database_cleaner, shoulda_matchers, etc.)
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  # Use transactional fixtures (automatically rolls back after each test)
  # Disable if using DatabaseCleaner with truncation strategy
  config.use_transactional_fixtures = true

  # Clear test log before suite
  config.before(:suite) do
    File.open("#{Rails.root}/log/test.log", 'w') { |file| file.truncate(0) }
    
    # Allow all hosts in tests (disable host authorization)
    Rails.application.config.hosts.clear if Rails.application.config.respond_to?(:hosts)
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