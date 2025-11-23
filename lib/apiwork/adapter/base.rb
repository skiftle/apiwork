# frozen_string_literal: true

module Apiwork
  module Adapter
    class Base
      def build_global_descriptors(builder)
        raise NotImplementedError, "#{self.class}#build_global_descriptors must be implemented"
      end

      def build_contract(contract_class, schema_data)
        raise NotImplementedError, "#{self.class}#build_contract must be implemented"
      end

      def build_action(action_definition, action_name, schema_data)
        raise NotImplementedError, "#{self.class}#build_action must be implemented"
      end

      def build_action_request(action_definition, request_definition, action_name, schema_data)
        raise NotImplementedError, "#{self.class}#build_action_request must be implemented"
      end

      def build_action_response(action_definition, response_definition, action_name, schema_data)
        raise NotImplementedError, "#{self.class}#build_action_response must be implemented"
      end

      def build_nested_writable_params(definition, schema_class, context, nested:)
        raise NotImplementedError, "#{self.class}#build_nested_writable_params must be implemented"
      end

      def collection_scope(collection, schema_data, query, metadata)
        raise NotImplementedError, "#{self.class}#collection_scope must be implemented"
      end

      def record_scope(record, schema_data, query, metadata)
        raise NotImplementedError, "#{self.class}#record_scope must be implemented"
      end

      def render_collection(collection, meta, query, metadata)
        raise NotImplementedError, "#{self.class}#render_collection must be implemented"
      end

      def render_record(record, meta, query, metadata)
        raise NotImplementedError, "#{self.class}#render_record must be implemented"
      end

      def render_errors(issues, metadata)
        raise NotImplementedError, "#{self.class}#render_errors must be implemented"
      end
    end
  end
end
