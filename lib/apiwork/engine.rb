# frozen_string_literal: true

module Apiwork
  class Engine < ::Rails::Engine
    isolate_namespace Apiwork
    engine_name 'apiwork'

    rake_tasks do
      load File.expand_path('../tasks/apiwork.rake', __dir__)
    end

    # Clear registry on code reload (development mode)
    # This ensures contracts are regenerated with updated schema code
    config.to_prepare do
      Apiwork::Contract::SchemaContractRegistry.clear!
    end
  end
end
