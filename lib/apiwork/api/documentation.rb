# frozen_string_literal: true

module Apiwork
  module API
    # Documentation DSL for API classes
    #
    # Provides: doc
    module Documentation
      # Define API-level documentation
      #
      # @yield Block for documentation DSL
      # @example
      #   doc do
      #     title "My API"
      #     version "1.0.0"
      #     description "Complete API for my application"
      #   end
      def doc(&block)
        builder = DocBuilder.new(level: :api)
        builder.instance_eval(&block)
        @metadata.doc = builder.documentation
      end
    end
  end
end
