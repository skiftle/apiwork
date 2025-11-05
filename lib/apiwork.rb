# frozen_string_literal: true

require_relative 'apiwork/version'
require_relative 'apiwork/configuration'
require_relative 'apiwork/error'

# Apiwork - A unified resource system for Rails APIs
module Apiwork
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def rack_app
      @rack_app ||= API::RackApp.new
    end

    alias_method :routes, :rack_app

    def register_generator(name, generator_class)
      Generation::Registry.register(name, generator_class)
    end

    def generate_schema(type, path, **options)
      Generation::Registry[type].generate(path, **options)
    end
  end
end

# Setup Zeitwerk autoloading for gem
require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  'api' => 'API',
  'openapi' => 'OpenAPI',
  'json_pointer' => 'JSONPointer',
  'api_inspector' => 'APIInspector'
)
loader.ignore("#{__dir__}/apiwork/version.rb")
loader.ignore("#{__dir__}/apiwork/configuration.rb")
loader.ignore("#{__dir__}/apiwork/error.rb")
loader.ignore("#{__dir__}/apiwork/engine.rb")
loader.setup
loader.eager_load

# Register built-in generators
Apiwork.register_generator(:openapi, Apiwork::Generation::OpenAPI)
Apiwork.register_generator(:transport, Apiwork::Generation::Transport)
Apiwork.register_generator(:zod, Apiwork::Generation::Zod)

# Load Rails Engine
require_relative 'apiwork/engine' if defined?(Rails::Engine)
