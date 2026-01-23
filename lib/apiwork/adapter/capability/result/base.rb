# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Result
        class Base
          attr_reader :data, :options, :request, :schema_class

          def initialize(context)
            @data = context.data
            @request = context.request
            @options = context.options
            @schema_class = context.schema_class
          end

          def apply
            raise NotImplementedError
          end

          def result(data: nil, includes: nil, serialize_options: nil, **additions)
            ApplyResult.new(
              additions:,
              data:,
              includes:,
              serialize_options:,
            )
          end
        end
      end
    end
  end
end
