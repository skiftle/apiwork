# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module RecordApplier
        class Context
          attr_reader :options, :record, :request, :schema_class

          def initialize(options:, record:, request:, schema_class:)
            @record = record
            @request = request
            @options = options
            @schema_class = schema_class
          end
        end
      end
    end
  end
end
