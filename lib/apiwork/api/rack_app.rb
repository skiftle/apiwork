# frozen_string_literal: true

module Apiwork
  module API
    class RackApp
      def call(env)
        route_set.call(env)
      rescue ActionController::RoutingError
        ErrorsController.action(:not_found).call(env)
      rescue ActionController::UnknownHttpMethod
        ErrorsController.action(:method_not_allowed).call(env)
      end

      private

      def route_set
        return Routing::Builder.new.build if Rails.env.development?

        @route_set ||= Routing::Builder.new.build
      end
    end
  end
end
