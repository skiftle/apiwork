# frozen_string_literal: true

# Set up the dummy Rails app environment
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('dummy/config/environment', __dir__)

# Load RSpec Rails
require 'rspec/rails'

# Load support files
Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

# Run migrations for test database
ActiveRecord::Migration.maintain_test_schema!

# Configure RSpec
RSpec.configure do |config|
  # Use transactional fixtures
  config.use_transactional_fixtures = true

  # Infer spec type from file location
  config.infer_spec_type_from_file_location!

  # Filter Rails gems from backtraces
  config.filter_rails_from_backtrace!

  # Prepare Apiwork before each test to ensure clean state
  config.before do
    Apiwork.prepare!(eager_load: true)
  end
end
