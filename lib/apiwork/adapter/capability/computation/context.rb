# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Computation
        class Context
          attr_reader :data, :options, :request, :schema_class

          def initialize(data:, options:, request:, schema_class:)
            @data = data
            @request = request
            @options = options
            @schema_class = schema_class
          end
        end
      end
    end
  end
end
