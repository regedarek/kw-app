# frozen_string_literal: true

RSpec.configure do |config|
  # Include Devise test helpers based on spec type
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  
  # Enable Warden test mode for all specs
  config.before(:suite) do
    Warden.test_mode!
  end
  
  # Clean up after Warden
  config.after(:each) do
    Warden.test_reset!
  end
end