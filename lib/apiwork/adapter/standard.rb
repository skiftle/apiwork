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
        # Load
        data, metadata = CollectionLoader.load(collection, schema_class, query, context).values_at(:data, :metadata)

        # Serialize
        serialized = schema_class.serialize(data, context: meta, includes: query[:include])

        # Render
        root_key = schema_class.root_key.plural
        response = { root_key => serialized }
        response[:pagination] = metadata[:pagination] if metadata[:pagination]
        response[:meta] = meta if meta.present?
        response
      end

      def render_record(record, schema_class, query, meta, context)
        return { meta: meta.presence || {} } if context.delete?

        # Load
        data, = RecordLoader.load(record, schema_class, query).values_at(:data, :metadata)

        # Serialize
        serialized = schema_class.serialize(data, context: meta, includes: query[:include])

        # Render
        root_key = schema_class.root_key.singular
        response = { root_key => serialized }
        response[:meta] = meta if meta.present?
        response
      end

      def render_error(issues, context)
        { issues: issues.map(&:to_h) }
      end
    end
  end
end
