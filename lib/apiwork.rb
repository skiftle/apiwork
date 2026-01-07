# frozen_string_literal: true

require 'zeitwerk'
require_relative 'apiwork/version'

# Apiwork is a Rails framework for building type-safe JSON APIs.
#
# Define APIs with resources, contracts, and schemas. Apiwork handles
# request validation, response serialization, and exports to OpenAPI, TypeScript, and Zod.
#
# @example Mount in routes
#   Rails.application.routes.draw do
#     mount Apiwork, at: '/'
#   end
module Apiwork
  class << self
    def call(env)
      routes.call(env)
    end

    # @api public
    # Prepares Apiwork for use by loading all components.
    #
    # Called by the Engine on startup and code reload. In tests, use
    # `eager_load: true` to ensure STI schema variants are registered.
    #
    # @param eager_load [Boolean] when true, eager loads all schemas
    #   to trigger STI variant registration. Default is false.
    #
    # @example Engine usage (default)
    #   Apiwork.prepare!
    #
    # @example Test setup
    #   before(:suite) { Apiwork.prepare!(eager_load: true) }
    #
    # @example Test cleanup (after creating custom fixtures)
    #   after { Apiwork.prepare!(eager_load: true) }
    #
    # @return [void]
    def prepare!(eager_load: false)
      API.reset!
      ErrorCode.reset!

      Adapter.register(Adapter::Standard)
      Export.register(Export::OpenAPI)
      Export.register(Export::Zod)
      Export.register(Export::TypeScript)

      load_api_definitions!
      eager_load_schemas! if eager_load
    end

    private

    def routes
      return draw_routes if reload_routes?

      @routes ||= draw_routes
    end

    def draw_routes
      API::Router.new.draw
    end

    def reload_routes?
      Rails.env.development?
    end

    def eager_load_schemas!
      Dir[Rails.root.join('app/schemas/**/*.rb')].sort.each do |file|
        require_dependency file
      end
    end

    def load_api_definitions!
      Dir[Rails.root.join('config/apis/**/*.rb')].sort.each(&method(:load))
    end
  end
end

loader = Zeitwerk::Loader.for_gem

loader.inflector.inflect(
  'api_registrar' => 'APIRegistrar',
  'api_serializer' => 'APISerializer',
  'api' => 'API',
  'json' => 'JSON',
  'json_pointer' => 'JSONPointer',
  'open_api' => 'OpenAPI',
  'type_script_mapper' => 'TypeScriptMapper',
  'uuid' => 'UUID',
)

loader.ignore("#{__dir__}/rubocop")
loader.ignore("#{__dir__}/generators")

loader.setup

require_relative 'apiwork/engine' if defined?(Rails::Engine)
