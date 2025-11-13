# frozen_string_literal: true

module Apiwork
  module API
    # Routing DSL for API classes
    #
    # Provides: resources, resource, concern, with_options
    #
    # Uses Rails-style convention-based resolution for contracts and controllers.
    # Resources are always auto-detected from namespace and resource name.
    #
    module Routing
      def resources(name, **options, &block)
        @recorder.resources(name, **options, &block)
      end

      def resource(name, **options, &block)
        @recorder.resource(name, **options, &block)
      end

      def concern(name, &block)
        @recorder.concern(name, &block)
      end

      def with_options(options = {}, &block)
        @recorder.with_options(options, &block)
      end
    end
  end
end
