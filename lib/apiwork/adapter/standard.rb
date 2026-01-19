# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      adapter_name :standard

      option :pagination, type: :hash do
        option :strategy, default: :offset, enum: %i[offset cursor], type: :symbol
        option :default_size, default: 20, type: :integer
        option :max_size, default: 100, type: :integer
      end

      api_builder APIBuilder
      contract_builder ContractBuilder

      transform_request RequestTransformer
      transform_request OpFieldTransformer, post: true

      def prepare_record(record, schema_class, state)
        RecordValidator.validate!(record, schema_class)
        RecordLoader.load(record, schema_class, state.request)
      end

      def prepare_collection(collection, schema_class, state)
        CollectionLoader.load(collection, schema_class, state)
      end

      def render_record(data, schema_class, state)
        {
          schema_class.root_key.singular => data,
          meta: state.meta.presence,
        }.compact
      end

      def render_collection(result, schema_class, state)
        {
          schema_class.root_key.plural => result[:data],
          pagination: result[:metadata][:pagination],
          meta: state.meta.presence,
        }.compact
      end

      def render_error(issues, layer, _state)
        {
          layer:,
          issues: issues.map(&:to_h),
        }
      end
    end
  end
end
