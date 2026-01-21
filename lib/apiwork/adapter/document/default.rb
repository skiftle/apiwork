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

        def build_record_response(response, data, state)
          response[schema_class.root_key.singular] = data
          response[:meta] = state.meta if state.meta.present?
        end

        def build_collection_response(response, data, state)
          response[schema_class.root_key.plural] = data
          response[:meta] = state.meta if state.meta.present?
        end

        def build_error_response(issues, layer, state)
          {
            issues:,
            layer:,
          }
        end
      end
    end
  end
end
