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

    def register_descriptors(api_class: nil, &block)
      builder = Contract::Descriptor::Builder.new(api_class: api_class, scope: nil)
      builder.instance_eval(&block)
    end

    def introspect(path)
      API.find(path)&.introspect
    end

    # Reset all registries
    # Useful for testing when you need to reload API configurations
    # Core descriptors will be registered per-API when APIs are configured
    def reset_registries!
      Contract::Descriptor::Registry.clear!
      API::Registry.clear!
      Contract::Descriptor::Core.reset!
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
