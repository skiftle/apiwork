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
    def reset!
      Adapter.reset!
      Generator.reset!
      API.reset!
      Descriptor.reset!
    end
  end
end

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  'api' => 'API',
  'json_pointer' => 'JSONPointer'
)
loader.ignore("#{__dir__}/rubocop")

loader.setup

require_relative 'apiwork/engine' if defined?(Rails::Engine)
