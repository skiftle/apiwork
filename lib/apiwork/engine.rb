# frozen_string_literal: true

module Apiwork
  class Engine < ::Rails::Engine
    isolate_namespace Apiwork
    engine_name 'apiwork'

    rake_tasks do
      load File.expand_path('../tasks/apiwork.rake', __dir__)
    end

    initializer 'apiwork.configure' do
      Apiwork.configure do |config|
        config.default_page_size = 20
        config.maximum_page_size = 200
      end
    end

    # Clear registry on code reload (development mode)
    # This ensures contracts are regenerated with updated schema code
    config.to_prepare do
      Apiwork::Contract::SchemaContractRegistry.clear!
    end
  end
end
