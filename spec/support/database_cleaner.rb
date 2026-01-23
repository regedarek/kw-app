# frozen_string_literal: true

require 'database_cleaner/active_record'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    
    # Reset all sequences to prevent ID conflicts
    ActiveRecord::Base.connection.tables.each do |table|
      next if table == 'schema_migrations' || table == 'ar_internal_metadata'
      
      begin
        ActiveRecord::Base.connection.reset_pk_sequence!(table)
      rescue StandardError => e
        Rails.logger.debug "Could not reset sequence for #{table}: #{e.message}"
      end
    end
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
  
  config.after(:each) do
    DatabaseCleaner.clean
  end
end