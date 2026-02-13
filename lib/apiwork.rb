# frozen_string_literal: true

require 'zeitwerk'
require_relative 'apiwork/version'

module Apiwork
  class << self
    def call(env)
      routes.call(env)
    end

    def prepare!(eager_load: false)
      API.clear!
      Adapter.clear!
      ErrorCode.clear!
      Export.clear!

      Adapter.register_defaults!
      ErrorCode.register_defaults!
      Export.register_defaults!

      load_api_definitions!
      eager_load_representations! if eager_load
    end

    private

    def routes
      return draw_routes if Rails.env.development?

      @routes ||= draw_routes
    end

    def draw_routes
      API::Router.route
    end

    def eager_load_representations!
      Dir[Rails.root.join('app/representations/**/*.rb')].sort.each(&method(:require_dependency))
    end

    def load_api_definitions!
      Dir[Rails.root.join('config/apis/**/*.rb')].sort.each(&method(:load))
    end
  end
end

loader = Zeitwerk::Loader.for_gem

loader.inflector.inflect(
  'api' => 'API',
  'api_builder' => 'APIBuilder',
  'api_serializer' => 'APISerializer',
  'json_pointer' => 'JSONPointer',
  'json' => 'JSON',
  'open_api' => 'OpenAPI',
  'type_script_mapper' => 'TypeScriptMapper',
  'uuid' => 'UUID',
)

loader.ignore("#{__dir__}/rubocop")
loader.ignore("#{__dir__}/generators")

loader.setup

require_relative 'apiwork/engine' if defined?(Rails::Engine)
