# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      def build_global_descriptors(builder, schema_data)
        DescriptorBuilder.build(builder, schema_data)
      end

      def build_contract(contract_class, schema_class, context)
        ContractBuilder.build(contract_class, schema_class, context)
      end

      def render_collection(collection, schema_class, query, meta, context)
        CollectionLoader.load(collection, schema_class, query, context) => { data:, metadata: }
        serialized = schema_class.serialize(data, context: meta, includes: query[:include])

        {
          schema_class.root_key.plural => serialized,
          pagination: metadata[:pagination],
          meta: meta.presence
        }.compact
      end

      def render_record(record, schema_class, query, meta, context)
        return { meta: meta.presence || {} } if context.delete?

        data = RecordLoader.load(record, schema_class, query)
        serialized = schema_class.serialize(data, context: meta, includes: query[:include])

        {
          schema_class.root_key.singular => serialized,
          meta: meta.presence
        }.compact
      end

      def render_error(issues, context)
        { issues: issues.map(&:to_h) }
      end
    end
  end
end
