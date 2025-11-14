# frozen_string_literal: true

module Apiwork
  class Engine < ::Rails::Engine
    isolate_namespace Apiwork
    engine_name 'apiwork'

    rake_tasks do
      load File.expand_path('../tasks/apiwork.rake', __dir__)
    end

    # Initialize gem on Rails boot and code reload
    config.to_prepare do
      # Clear registry on code reload (development mode)
      Apiwork::Contract::SchemaContractRegistry.clear!

      # Register built-in types
      Apiwork::Contract::BuiltInTypes.register

      # Register generators
      Apiwork.register_generator(:openapi, Apiwork::Generation::Generators::OpenAPI)
      Apiwork.register_generator(:zod, Apiwork::Generation::Generators::Zod)
      Apiwork.register_generator(:typescript, Apiwork::Generation::Generators::Typescript)
    end
  end
end
