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

      def register_api(registrar, capabilities)
        APIBuilder.build(registrar, capabilities)
      end

      def register_contract(registrar, schema_class, actions)
        ContractBuilder.build(registrar, schema_class, actions)
      end

      def render_collection(collection, schema_class, state)
        CollectionLoader.load(collection, schema_class, state) => { data:, metadata: }
        data = schema_class.serialize(data, context: state.context, include: state.query[:include])

        {
          schema_class.root_key.plural => data,
          pagination: metadata[:pagination],
          meta: state.meta.presence,
        }.compact
      end

      def render_record(record, schema_class, state)
        RecordValidator.validate!(record, schema_class)

        data = RecordLoader.load(record, schema_class, state.query)
        data = schema_class.serialize(data, context: state.context, include: state.query[:include])

        {
          schema_class.root_key.singular => data,
          meta: state.meta.presence,
        }.compact
      end

      def render_error(layer, issues, state)
        {
          layer:,
          issues: issues.map(&:to_h),
        }
      end

      def transform_request(hash)
        RequestTransformer.transform(hash)
      end
    end
  end
end
