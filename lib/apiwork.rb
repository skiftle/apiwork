# frozen_string_literal: true

# Core
require_relative 'apiwork/version'
require_relative 'apiwork/configuration'

# Errors
require_relative 'apiwork/errors/json_pointer'
require_relative 'apiwork/errors/base'
require_relative 'apiwork/errors/rails_converter'
require_relative 'apiwork/errors/handler'

# Utilities
require_relative 'apiwork/transform/case'

# Controller
require_relative 'apiwork/controller/concern'

# Resource
require_relative 'apiwork/resource/resolver'
require_relative 'apiwork/resource/base'

# Contract
require_relative 'apiwork/contract/validation_error'
require_relative 'apiwork/contract/coercer'
require_relative 'apiwork/contract/type_checker'
require_relative 'apiwork/contract/definition'
require_relative 'apiwork/contract/base'
require_relative 'apiwork/contract/generator'
require_relative 'apiwork/contract/resolver'
require_relative 'apiwork/contract/schema_builder'

# Introspection
require_relative 'apiwork/introspection/inspector'

# API
require_relative 'apiwork/api/metadata'
require_relative 'apiwork/api/configuration'
require_relative 'apiwork/api/documentation_builder'
require_relative 'apiwork/api/documentation'
require_relative 'apiwork/api/routing'
require_relative 'apiwork/api/routing/builder'
require_relative 'apiwork/api/recorder/concerns'
require_relative 'apiwork/api/recorder/inference'
require_relative 'apiwork/api/recorder/resources'
require_relative 'apiwork/api/recorder/actions'
require_relative 'apiwork/api/recorder'
require_relative 'apiwork/api/base'
require_relative 'apiwork/api/rack_app'
require_relative 'apiwork/api/registry'
require_relative 'apiwork/api'

# Generation
require_relative 'apiwork/generation/base'
require_relative 'apiwork/generation/registry'
require_relative 'apiwork/generation/transport'
require_relative 'apiwork/generation/zod'
require_relative 'apiwork/generation/openapi'
require_relative 'apiwork/generation/options'
require_relative 'apiwork/generation/schema/writer'
require_relative 'apiwork/generation/schema'

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

# Register built-in generators
Apiwork.register_generator(:openapi, Apiwork::Generation::OpenAPI)
Apiwork.register_generator(:transport, Apiwork::Generation::Transport)
Apiwork.register_generator(:zod, Apiwork::Generation::Zod)

# Rails integration
require_relative 'apiwork/engine' if defined?(Rails::Engine)
