# frozen_string_literal: true

require 'zeitwerk'
require_relative 'apiwork/version'

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
  'api' => 'API',
  'api_registrar' => 'APIRegistrar',
  'json_pointer' => 'JSONPointer',
  'open_api_spec' => 'OpenAPISpec',
  'type_script_spec' => 'TypeScriptSpec'
)

loader.ignore("#{__dir__}/rubocop")
loader.ignore("#{__dir__}/generators")

loader.setup

require_relative 'apiwork/engine' if defined?(Rails::Engine)
