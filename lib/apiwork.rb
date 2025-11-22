# frozen_string_literal: true

require 'zeitwerk'
require_relative 'apiwork/version'

module Apiwork
  class << self
    # DOCUMENTATION
    def routes
      @routes ||= API::RackApp.new
    end

    # DOCUMENTATION
    def reset_registries!
      API::Registry.clear!
      Contract::SchemaRegistry.clear!
      Contract::Descriptor::Registry.clear!
      Contract::Descriptor::Core.clear!
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
