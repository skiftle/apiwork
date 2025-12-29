# frozen_string_literal: true

module Apiwork
  module Adapter
    class StandardAdapter < Base
      adapter_name :standard

      option :pagination, type: :hash do
        option :strategy, default: :offset, enum: %i[offset cursor], type: :symbol
        option :default_size, default: 20, type: :integer
        option :max_size, default: 100, type: :integer
      end

      def register_api(registrar, schema_summary)
        TypeSystemBuilder.build(registrar, schema_summary)
      end

      def register_contract(registrar, schema_class, actions:)
        ContractBuilder.build(registrar, schema_class, actions)
      end

      def render_collection(collection, schema_class, action_summary)
        CollectionLoader.load(collection, schema_class, action_summary) => { data:, metadata: }
        serialized = schema_class.serialize(data, context: action_summary.context, include: action_summary.query[:include])

        {
          schema_class.root_key.plural => serialized,
          pagination: metadata[:pagination],
          meta: action_summary.meta.presence
        }.compact
      end

      def render_record(record, schema_class, action_summary)
        RecordValidator.validate(record, schema_class)
        data = RecordLoader.load(record, schema_class, action_summary.query)
        serialized = schema_class.serialize(data, context: action_summary.context, include: action_summary.query[:include])

        {
          schema_class.root_key.singular => serialized,
          meta: action_summary.meta.presence
        }.compact
      end

      def render_error(layer, issues, action_summary)
        {
          layer:,
          issues: issues.map(&:to_h)
        }
      end

      def transform_request(hash)
        RequestTransformer.transform(hash)
      end
    end
  end
end
