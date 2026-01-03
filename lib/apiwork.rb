# frozen_string_literal: true

require 'zeitwerk'
require_relative 'apiwork/version'

# Apiwork is a Rails framework for building type-safe JSON APIs.
#
# Define APIs with resources, contracts, and schemas. Apiwork handles
# request validation, response serialization, and generates specs.
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
