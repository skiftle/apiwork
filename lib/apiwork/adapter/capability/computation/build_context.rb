# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Computation
        class BuildContext
          attr_reader :additions, :options, :schema_class

          def initialize(additions:, options:, schema_class:)
            @additions = additions
            @options = options
            @schema_class = schema_class
          end
        end
      end
    end
  end
end
