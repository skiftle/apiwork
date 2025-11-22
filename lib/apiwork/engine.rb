# frozen_string_literal: true

module Apiwork
  class Engine < ::Rails::Engine
    isolate_namespace Apiwork
    engine_name 'apiwork'

    rake_tasks do
      load File.expand_path('../tasks/apiwork.rake', __dir__)
    end

    config.to_prepare do
      Apiwork::Generator::Registry.clear!
      Apiwork::Contract::SchemaRegistry.clear!
      Apiwork::API::Registry.clear!
      Apiwork::Descriptor.clear!

      Apiwork::Generator.register(:openapi, Apiwork::Generator::Openapi)
      Apiwork::Generator.register(:zod, Apiwork::Generator::Zod)
      Apiwork::Generator.register(:typescript, Apiwork::Generator::Typescript)

      if Rails.root.join('config/apis').exist?
        Dir[Rails.root.join('config/apis/**/*.rb')].sort.each do |file|
          load file
        end
      end
    end
  end
end
