# frozen_string_literal: true

module Apiwork
  class Engine < ::Rails::Engine
    isolate_namespace Apiwork
    engine_name 'apiwork'

    rake_tasks do
      load File.expand_path('../tasks/apiwork.rake', __dir__)
    end

    config.to_prepare do
      # Clear all registries on code reload (development mode)
      Apiwork::Contract::SchemaRegistry.clear!
      Apiwork::API::Registry.clear!
      Apiwork::Contract::Descriptor::Registry.clear!

      # Register generators
      Apiwork.register_generator(:openapi, Apiwork::Generator::Openapi)
      Apiwork.register_generator(:zod, Apiwork::Generator::Zod)
      Apiwork.register_generator(:typescript, Apiwork::Generator::Typescript)

      if Rails.root.join('config/apis').exist?
        Dir[Rails.root.join('config/apis/**/*.rb')].sort.each do |file|
          load file
        end
      end
    end
  end
end
