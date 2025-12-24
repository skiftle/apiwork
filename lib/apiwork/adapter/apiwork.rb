# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      adapter_name :apiwork

      option :pagination, type: :hash do
        option :strategy, type: :symbol, default: :offset, enum: %i[offset cursor]
        option :default_size, type: :integer, default: 20
        option :max_size, type: :integer, default: 100
      end

      def register_api(registrar, schema_data)
        TypeSystemBuilder.build(registrar, schema_data)
      end

      def register_contract(registrar, schema_class, actions:)
        ContractBuilder.build(registrar, schema_class, actions)
      end

      def render_collection(collection, schema_class, action_data)
        CollectionLoader.load(collection, schema_class, action_data) => { data:, metadata: }
        serialized = schema_class.serialize(data, context: action_data.context, include: action_data.query[:include])

        {
          schema_class.root_key.plural => serialized,
          pagination: metadata[:pagination],
          meta: action_data.meta.presence
        }.compact
      end

      def render_record(record, schema_class, action_data)
        RecordValidator.validate(record, schema_class)
        data = RecordLoader.load(record, schema_class, action_data.query)
        serialized = schema_class.serialize(data, context: action_data.context, include: action_data.query[:include])

        {
          schema_class.root_key.singular => serialized,
          meta: action_data.meta.presence
        }.compact
      end

      def render_error(issues, layer, action_data)
        {
          layer:,
          issues: issues.map(&:to_h)
        }
      end

      def transform_request(hash)
        ParamsNormalizer.call(hash)
      end

      def transform_response(hash)
        hash
      end
    end
  end
end
