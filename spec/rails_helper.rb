ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'support/controller_helper'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.before :suite do
    File.open("#{Rails.root}/log/test.log", 'w') { |file| file.truncate(0) }
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.mock_with :rspec do |c|
    c.syntax = :expect
    c.allow_message_expectations_on_nil = true
  end

  config.include ControllerHelper

  config.infer_spec_type_from_file_location!
end
