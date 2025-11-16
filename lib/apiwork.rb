# frozen_string_literal: true

require 'zeitwerk'
require_relative 'apiwork/version'

module Apiwork
  class << self
    def routes
      @routes ||= API::RackApp.new
    end

    def register_generator(name, generator_class)
      Generator::Registry.register(name, generator_class)
    end

    def generate_spec(type, path, **options)
      Generator::Registry[type].generate(path: path, **options)
    end

    def introspect(path)
      API.find(path)&.introspect
    end

    # Reset all registries
    # Useful for testing when you need to reload API configurations
    # Core descriptors will be registered per-API when APIs are configured
    # Note: Generator::Registry is NOT cleared here as generators are statically
    # registered at gem load time and don't need to be reset during API reloading
    def reset_registries!
      API::Registry.clear!
      Contract::SchemaRegistry.clear!
      Contract::Descriptor::Registry.clear!
      Contract::Descriptor::Core.clear!
    end
  end
end

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  'api' => 'API',
  'json_pointer' => 'JSONPointer'
)

loader.setup

require_relative 'apiwork/engine' if defined?(Rails::Engine)
