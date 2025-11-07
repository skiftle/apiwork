# frozen_string_literal: true

require 'zeitwerk'
require_relative 'apiwork/version'

# Apiwork - A unified resource system for Rails APIs
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

    def generate_schema(type, path, **options)
      Generation::Registry[type].generate(path, **options)
    end

    # Register global types (shared across all contracts)
    #
    # Global types are available in all contracts and don't need prefixing.
    # Examples: string_filter, integer_filter, page_params
    #
    # @example Register custom global types
    #   Apiwork.register_global_types do
    #     type :currency_filter do
    #       param :eq, type: :string
    #       param :in, type: :array, of: :string
    #     end
    #   end
    #
    # @yield Block evaluated with GlobalTypeBuilder DSL
    def register_global_types(&block)
      builder = Contract::GlobalTypeBuilder.new
      builder.instance_eval(&block)
    end
  end
end

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  'api' => 'API',
  'openapi' => 'OpenAPI',
  'json_pointer' => 'JSONPointer'
)
loader.ignore("#{__dir__}/apiwork/version.rb")
loader.ignore("#{__dir__}/apiwork/engine.rb")
loader.setup
loader.eager_load

# Register built-in generators
Apiwork.register_generator(:openapi, Apiwork::Generation::OpenAPI)
Apiwork.register_generator(:transport, Apiwork::Generation::Transport)
Apiwork.register_generator(:zod, Apiwork::Generation::Zod)

# Rails integration
require_relative 'apiwork/engine' if defined?(Rails::Engine)
