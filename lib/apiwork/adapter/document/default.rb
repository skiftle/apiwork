# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      class Default < Base
        response_types Types::Responses

        attr_reader :schema_class

        def initialize(schema_class)
          super()
          @schema_class = schema_class
        end

        def build_record_response(record, additions, state)
          {
            schema_class.root_key.singular => record,
            **additions,
            meta: state.meta.presence,
          }.compact
        end

        def build_collection_response(collection, additions, state)
          {
            schema_class.root_key.plural => collection,
            **additions,
            meta: state.meta.presence,
          }.compact
        end

        def build_error_response(error, state)
          error
        end
      end
    end
  end
end
