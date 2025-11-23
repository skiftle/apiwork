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
  # Include ApiworkHelpers for specs tagged with type: :apiwork
  config.include ApiworkHelpers, type: :apiwork

  # Use transactional fixtures
  config.use_transactional_fixtures = true

  # Infer spec type from file location
  config.infer_spec_type_from_file_location!

  # Filter Rails gems from backtraces
  config.filter_rails_from_backtrace!

  # Clear registries before each test, but skip integration tests
  # Integration tests use before(:all) to load API config once for performance
  config.before do |example|
    Apiwork::Descriptor.reset! unless [:request, :integration].include?(example.metadata[:type])
  end

  # Ensure APIs are loaded for request/integration specs
  # These spec types don't reset between tests, so they rely on APIs being loaded once
  # If another spec called API.reset! before them, we need to reload
  config.before(:each, type: :request) do
    if Apiwork::API::Registry.all.empty? && Rails.root.join('config/apis').exist?
      Dir[Rails.root.join('config/apis/**/*.rb')].sort.each do |file|
        load file
      end
    end
  end

  config.before(:each, type: :integration) do
    if Apiwork::API::Registry.all.empty? && Rails.root.join('config/apis').exist?
      Dir[Rails.root.join('config/apis/**/*.rb')].sort.each do |file|
        load file
      end
    end
  end
end
