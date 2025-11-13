# frozen_string_literal: true

module Apiwork
  module API
    # Documentation DSL for API classes
    #
    # Provides: doc
    module Documentation
      def doc(&block)
        builder = DocumentationBuilder.new(level: :api)
        builder.instance_eval(&block)
        @metadata.doc = builder.documentation
      end
    end
  end
end
