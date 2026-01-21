# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class Document < Adapter::Document::Base
        response_types Types::Responses

        attr_reader :schema_class

        def initialize(schema_class)
          super()
          @schema_class = schema_class
        end

        def build_record_response(data, metadata, state)
          {
            schema_class.root_key.singular => data,
            **metadata,
            meta: state.meta.presence,
          }.compact
        end

        def build_collection_response(data, metadata, state)
          {
            schema_class.root_key.plural => data,
            **metadata,
            meta: state.meta.presence,
          }.compact
        end

        def build_error_response(issues, layer, state)
          {
            layer:,
            issues: issues.map(&:to_h),
          }
        end
      end
    end
  end
end
