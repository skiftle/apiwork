# frozen_string_literal: true

module Apiwork
  class Engine < ::Rails::Engine
    isolate_namespace Apiwork
    engine_name 'apiwork'

    rake_tasks do
      load File.expand_path('../tasks/apiwork.rake', __dir__)
    end

    config.to_prepare do
      Apiwork.reset!

      Apiwork::Adapter.register(Apiwork::Adapter::Apiwork)

      Apiwork::Spec.register(Apiwork::Spec::Openapi)
      Apiwork::Spec.register(Apiwork::Spec::Zod)
      Apiwork::Spec.register(Apiwork::Spec::Typescript)

      if Rails.root.join('config/apis').exist?
        Dir[Rails.root.join('config/apis/**/*.rb')].sort.each do |file|
          load file
        end
      end
    end
  end
end
