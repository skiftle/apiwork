# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      identifier :apiwork

      option :pagination, type: :hash do
        option :strategy, type: :symbol, default: :page, enum: %i[page cursor]
        option :default_size, type: :integer, default: 20
        option :max_size, type: :integer, default: 100
      end

      def register_api_types(type_registrar, schema_data)
        TypeSystemBuilder.build(type_registrar, schema_data)
      end

      def register_contract_types(type_registrar, schema_class, actions:)
        ContractBuilder.build(type_registrar, schema_class, actions)
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
        return { meta: action_data.meta.presence || {} } if action_data.delete?

        RecordValidator.validate(record, schema_class:)
        data = RecordLoader.load(record, schema_class, action_data.query)
        serialized = schema_class.serialize(data, context: action_data.context, include: action_data.query[:include])

        {
          schema_class.root_key.singular => serialized,
          meta: action_data.meta.presence
        }.compact
      end

      def render_error(issues, action_data)
        { issues: issues.map(&:to_h) }
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
