# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module RecordApplier
        class Base
          attr_reader :options, :record, :request, :schema_class

          def initialize(context)
            @record = context.record
            @request = context.request
            @options = context.options
            @schema_class = context.schema_class
          end

          def apply
            raise NotImplementedError
          end

          def result(record: nil, includes: nil, serialize_options: nil, **additions)
            ApplyResult.new(
              additions:,
              includes:,
              serialize_options:,
              data: record,
            )
          end
        end
      end
    end
  end
end
