# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      class CollectionSerializer
        def self.serialize(load_result, context, query, schema_class)
          new(load_result, context, query, schema_class).serialize
        end

        def initialize(load_result, context, query, schema_class)
          @load_result = load_result
          @context = context
          @query = query
          @schema_class = schema_class
        end

        def serialize
          @schema_class.serialize(@load_result.data, context: @context, includes: @query[:include])
        end
      end
    end
  end
end
