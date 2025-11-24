# frozen_string_literal: true

module Apiwork
  module Adapter
    class Base
      def build_global_descriptors(builder)
        raise NotImplementedError, "#{self.class}#build_global_descriptors must be implemented"
      end

      def build_contract(contract_class, schema_class, context)
        raise NotImplementedError, "#{self.class}#build_contract must be implemented"
      end

      def collection_scope(collection, schema_class, query, context)
        raise NotImplementedError, "#{self.class}#collection_scope must be implemented"
      end

      def record_scope(record, schema_class, query, context)
        raise NotImplementedError, "#{self.class}#record_scope must be implemented"
      end

      def render_collection(collection, meta, query, schema_class, context)
        raise NotImplementedError, "#{self.class}#render_collection must be implemented"
      end

      def render_record(record, meta, query, schema_class, context)
        raise NotImplementedError, "#{self.class}#render_record must be implemented"
      end

      def render_error(issues, context)
        raise NotImplementedError, "#{self.class}#render_error must be implemented"
      end
    end
  end
end
