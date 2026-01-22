# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module CollectionApplier
        class Base
          attr_reader :collection, :options, :request, :schema_class

          def initialize(context)
            @collection = context.collection
            @request = context.request
            @options = context.options
            @schema_class = context.schema_class
          end

          def apply
            raise NotImplementedError
          end

          def result(collection: nil, includes: nil, serialize_options: nil, **additions)
            ApplyResult.new(
              additions:,
              includes:,
              serialize_options:,
              data: collection,
            )
          end
        end
      end
    end
  end
end
