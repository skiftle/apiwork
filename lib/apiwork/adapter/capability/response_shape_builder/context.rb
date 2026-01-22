# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module ResponseShapeBuilder
        class Context
          attr_reader :options, :schema_class, :target

          def initialize(options:, schema_class:, target:)
            @schema_class = schema_class
            @options = options
            @target = target
          end
        end
      end
    end
  end
end
