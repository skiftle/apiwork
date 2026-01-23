# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Computation
        class Base
          attr_reader :data, :options, :request, :schema_class

          class << self
            def scope(value = nil)
              @scope = value if value
              @scope
            end
          end

          def initialize(context)
            @data = context.data
            @request = context.request
            @options = context.options
            @schema_class = context.schema_class
          end

          def apply
            raise NotImplementedError
          end

          def result(data: nil, document: nil, includes: nil, serialize_options: nil)
            ApplyResult.new(
              data:,
              document:,
              includes:,
              serialize_options:,
            )
          end
        end
      end
    end
  end
end
