# frozen_string_literal: true

require_relative 'routing/builder'

module Apiwork
  module API
    # Rack application for mounting Apiwork APIs
    #
    # Usage:
    #   mount Apiwork.rack_app => '/'
    class RackApp
      def call(env)
        route_set.call(env)
      end

      private

      def route_set
        return build_route_set if development?

        @route_set ||= build_route_set
      end

      def build_route_set
        Routing::Builder.new.build
      end

      def development?
        defined?(::Rails) && ::Rails.env.development?
      end
    end
  end
end
