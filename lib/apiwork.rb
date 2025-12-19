# frozen_string_literal: true

require 'zeitwerk'
require_relative 'apiwork/version'

module Apiwork
  class << self
    def call(env)
      route_set.call(env)
    end

    def reset!
      API.reset!
      ErrorCode.reset!
    end

    private

    def route_set
      return API::Routing::Builder.new.build if Rails.env.development?

      @route_set ||= API::Routing::Builder.new.build
    end
  end
end

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  'api' => 'API',
  'json_pointer' => 'JSONPointer'
)
loader.ignore("#{__dir__}/rubocop")
loader.ignore("#{__dir__}/generators")

loader.setup

require_relative 'apiwork/engine' if defined?(Rails::Engine)
