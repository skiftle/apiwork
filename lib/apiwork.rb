# frozen_string_literal: true

require 'zeitwerk'
require_relative 'apiwork/version'

module Apiwork
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def routes
      @routes ||= API::RackApp.new
    end

    def register_generator(name, generator_class)
      Generator::Registry.register(name, generator_class)
    end

    def generate_spec(type, path, **options)
      Generator::Registry[type].generate(path: path, **options)
    end

    def register_descriptors(&block)
      builder = Contract::Descriptors::GlobalBuilder.new
      builder.instance_eval(&block)
    end

    def introspect(path)
      API.find(path)&.introspect
    end

    # Reset all registries and re-register built-in types
    # Useful for testing when you need to reload API configurations
    def reset_registries!
      Contract::Descriptors::Registry.clear!
      API::Registry.clear!
      Contract::BuiltInTypes.reset!
      Contract::BuiltInTypes.register_core_descriptors
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
