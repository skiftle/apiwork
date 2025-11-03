# frozen_string_literal: true

require 'zeitwerk'
require_relative 'apiwork/version'

# Apiwork - A unified resource system for Rails APIs
# Provides filtering, sorting, pagination, and serialization in one DSL
module Apiwork
  # Configuration
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    # Returns a Rack application for mounting in routes
    #
    # Usage:
    #   mount Apiwork.routes => '/'
    def routes
      @routes ||= API::Routes.new
    end

    # Register a custom generator
    #
    # @param name [Symbol] Generator name (e.g., :openapi, :graphql)
    # @param generator_class [Class] Generator class (must inherit from Generation::Base)
    # @raise [ArgumentError] if generator doesn't inherit from Base
    #
    # @example
    #   Apiwork.register_generator(:graphql, MyGraphQLGenerator)
    def register_generator(name, generator_class)
      Generation::Registry.register(name, generator_class)
    end

    # Generate schema programmatically
    #
    # @param type [Symbol] Generator type (e.g., :openapi, :transport)
    # @param path [String] API mount path (e.g., '/api/v1')
    # @param options [Hash] Generator-specific options
    # @return [String, Hash] Generated schema content
    #
    # @example
    #   schema = Apiwork.generate_schema(:openapi, '/api/v1')
    def generate_schema(type, path, **options)
      Generation::Registry[type].generate(path, **options)
    end
  end
end

# Setup Zeitwerk loader FIRST before any requires
loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/apiwork", namespace: Apiwork)
loader.inflector.inflect(
  'api' => 'API'
)
# Ignore files and directories that are manually required to avoid conflicts
loader.ignore("#{__dir__}/apiwork/version.rb")
loader.ignore("#{__dir__}/apiwork/configuration.rb")
loader.ignore("#{__dir__}/apiwork/errors")
loader.ignore("#{__dir__}/apiwork/transform")
loader.ignore("#{__dir__}/apiwork/controller")
loader.ignore("#{__dir__}/apiwork/resource")
loader.ignore("#{__dir__}/apiwork/contract")
loader.ignore("#{__dir__}/apiwork/introspection")
loader.ignore("#{__dir__}/apiwork/generation")
loader.ignore("#{__dir__}/apiwork/rails")
loader.ignore("#{__dir__}/apiwork/app")
loader.setup

require_relative 'apiwork/configuration'

require_relative 'apiwork/errors/json_pointer'
require_relative 'apiwork/errors/errors'
require_relative 'apiwork/errors/rails_converter'
require_relative 'apiwork/errors/handler'

require_relative 'apiwork/transform/case'

require_relative 'apiwork/controller/concern'

require_relative 'apiwork/resource/resolver'
require_relative 'apiwork/resource/base'

# Contract system
require_relative 'apiwork/contract/validation_error'
require_relative 'apiwork/contract/coercer'
require_relative 'apiwork/contract/type_checker'
require_relative 'apiwork/contract/definition'
require_relative 'apiwork/contract/base'
require_relative 'apiwork/contract/generator'
require_relative 'apiwork/contract/resolver'
require_relative 'apiwork/contract/schema_builder'

require_relative 'apiwork/introspection/inspector'

require_relative 'apiwork/generation/base'
require_relative 'apiwork/generation/registry'

# These should be moved to their own gems later
require_relative 'apiwork/generation/transport'
require_relative 'apiwork/generation/zod'
require_relative 'apiwork/generation/openapi'
Apiwork.register_generator(:openapi, Apiwork::Generation::OpenAPI)
Apiwork.register_generator(:transport, Apiwork::Generation::Transport)
Apiwork.register_generator(:zod, Apiwork::Generation::Zod)

# Schema generation to static files
require_relative 'apiwork/generation/options'
require_relative 'apiwork/generation/schema/writer'
require_relative 'apiwork/generation/schema'

# Rails integration
if defined?(Rails)
  require_relative 'apiwork/rails/engine'

  # Load controllers
  require_relative 'apiwork/app/controllers/apiwork/schemas_controller'
end
