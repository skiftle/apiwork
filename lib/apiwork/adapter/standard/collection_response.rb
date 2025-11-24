# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      class CollectionResponse
        def self.render(load_result, meta, query, schema_class, context)
          new(load_result, meta, query, schema_class, context).render
        end

        def initialize(load_result, meta, query, schema_class, context)
          @load_result = load_result
          @meta = meta
          @query = query
          @schema_class = schema_class
          @context = context
        end

        def render
          root_key = @schema_class.root_key.plural
          collection = @load_result.data

          response = { root_key => collection }
          response[:pagination] = @load_result.metadata[:pagination] if @load_result.metadata[:pagination]
          response[:meta] = @meta if @meta.present?
          response
        end
      end
    end
  end
end
