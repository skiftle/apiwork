# frozen_string_literal: true

# Set up the dummy Rails app environment
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../dummy/config/environment', __FILE__)

# Load RSpec Rails
require 'rspec/rails'

# Load support files
Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

# Run migrations for test database
ActiveRecord::Migration.maintain_test_schema!

# Configure RSpec
RSpec.configure do |config|
  # Include ApiworkHelpers for specs tagged with type: :apiwork
  config.include ApiworkHelpers, type: :apiwork

  # Use transactional fixtures
  config.use_transactional_fixtures = true

  # Infer spec type from file location
  config.infer_spec_type_from_file_location!

  # Filter Rails gems from backtraces
  config.filter_rails_from_backtrace!

  # Clear schema-contract registry before each test
  # This ensures tests don't interfere with each other
  config.before(:each) do
    Apiwork::Contract::SchemaContractRegistry.clear!
  end
end
