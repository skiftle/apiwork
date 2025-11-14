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
      Generation::Registry.register(name, generator_class)
    end

    def generate_spec(type, path, **options)
      Generation::Registry[type].generate(path: path, **options)
    end

    def register_global_descriptors(&block)
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
      Contract::BuiltInTypes.register
    end
  end
end

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  'api' => 'API',
  'openapi' => 'OpenAPI',
  'json_pointer' => 'JSONPointer'
)

# error.rb contains multiple classes, so we need to require it explicitly
loader.ignore("#{__dir__}/apiwork/error.rb")

loader.setup

# Explicitly require files that Zeitwerk ignores
require_relative 'apiwork/error'

require_relative 'apiwork/engine' if defined?(Rails::Engine)
