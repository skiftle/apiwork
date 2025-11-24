# frozen_string_literal: true

module Apiwork
  module Adapter
    class Base
      def build_global_descriptors(builder, schema_data)
        raise NotImplementedError
      end

      def build_contract(contract_class, schema_class, context)
        raise NotImplementedError
      end

      def collection_scope(collection, schema_class, query, context)
        raise NotImplementedError
      end

      def record_scope(record, schema_class, query, context)
        raise NotImplementedError
      end

      def render_collection(collection, meta, query, schema_class, context)
        raise NotImplementedError
      end

      def render_record(record, meta, query, schema_class, context)
        raise NotImplementedError
      end

      def render_error(issues, context)
        raise NotImplementedError
      end
    end
  end
end
