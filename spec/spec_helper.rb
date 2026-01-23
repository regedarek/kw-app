# frozen_string_literal: true

# Coverage reporting (MUST load before Rails)
# Run with: COVERAGE=true bundle exec rspec
if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start 'rails' do
    enable_coverage :branch

    add_filter %w[
      /spec/
      /config/
      /vendor/
      /lib/tasks/
    ]

    add_group 'Models', 'app/models'
    add_group 'Controllers', 'app/controllers'
    add_group 'Services', 'app/services'
    add_group 'Jobs', 'app/jobs'
    add_group 'Components', 'app/components'

    minimum_coverage 80
  end
end

# WebMock for HTTP request stubbing
require 'webmock/rspec'

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: ['chromedriver.storage.googleapis.com']
)

RSpec.configure do |config|
  # Expectations
  config.expect_with :rspec do |expectations|
    # Use expect syntax exclusively
    expectations.syntax = :expect
    
    # Include chain clauses for better matcher descriptions
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # Mocks
  config.mock_with :rspec do |mocks|
    # Use expect syntax exclusively
    mocks.syntax = :expect
    
    # Verify partial doubles (catch typos in mocked methods)
    mocks.verify_partial_doubles = true
  end

  # Shared context/example group setup
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Output
  config.color = true
  config.tty = true

  # Focus on specific tests with :focus tag
  config.filter_run_when_matching :focus
  
  # Run all tests if everything is filtered out
  config.run_all_when_everything_filtered = true

  # Randomize test order to catch test interdependencies
  config.order = :random
  Kernel.srand config.seed

  # Profile slowest tests (show top 10)
  config.profile_examples = 10 if ENV['PROFILE']

  # Persist example status for --only-failures and --next-failure
  config.example_status_persistence_file_path = 'tmp/rspec_examples.txt'

  # Output format for single test runs (use explicit class name)
  config.default_formatter = RSpec::Core::Formatters::DocumentationFormatter if config.files_to_run.one?

  # Suppress warnings
  config.warnings = false
end