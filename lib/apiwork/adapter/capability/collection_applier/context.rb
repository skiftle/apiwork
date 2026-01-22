# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module CollectionApplier
        class Context
          attr_reader :collection, :options, :request, :schema_class

          def initialize(collection:, options:, request:, schema_class:)
            @collection = collection
            @request = request
            @options = options
            @schema_class = schema_class
          end
        end
      end
    end
  end
end
