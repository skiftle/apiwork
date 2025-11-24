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

      def render_collection(load_result, meta, query, schema_class, context)
        CollectionResponse.render(load_result, meta, query, schema_class, context)
      end

      def render_record(load_result, meta, query, schema_class, context)
        RecordResponse.render(load_result, meta, query, schema_class, context)
      end

      def render_error(issues, context)
        ErrorResponse.render(issues, context)
      end
    end
  end
end
