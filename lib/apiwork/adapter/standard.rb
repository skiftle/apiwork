# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      def build_global_descriptors(builder, schema_data)
        DescriptorBuilder.build(builder, schema_data)
      end

      def build_contract(contract_class, schema_class, actions:)
        ContractBuilder.build(contract_class, schema_class, actions)
      end

      def render_collection(collection, schema_class, action_data)
        CollectionLoader.load(collection, schema_class, action_data.query, action_data) => { data:, metadata: }
        serialized = schema_class.serialize(data, context: action_data.context, include: action_data.query[:include])

        {
          schema_class.root_key.plural => serialized,
          pagination: metadata[:pagination],
          meta: action_data.meta.presence
        }.compact
      end

      def render_record(record, schema_class, action_data)
        return { meta: action_data.meta.presence || {} } if action_data.delete?

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
    end
  end
end
