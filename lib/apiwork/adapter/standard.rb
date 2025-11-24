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

      def load_collection(collection, schema_class, query, context)
        CollectionLoader.load(collection, schema_class, query, context)
      end

      def load_record(record, schema_class, query, context)
        RecordLoader.load(record, schema_class, query)
      end

      def render_collection(load_result, user_meta, query, schema_class, context)
        root_key = schema_class.root_key.plural
        collection = load_result.data

        response = { root_key => collection }
        response[:pagination] = load_result.metadata[:pagination] if load_result.metadata[:pagination]
        response[:meta] = user_meta if user_meta.present?
        response
      end

      def render_record(load_result, user_meta, query, schema_class, context)
        return { meta: user_meta.presence || {} } if context.delete?

        root_key = schema_class.root_key.singular
        record = load_result.data

        response = { root_key => record }
        response[:meta] = user_meta if user_meta.present?
        response
      end

      def render_error(issues, context)
        { issues: issues.map(&:to_h) }
      end
    end
  end
end
