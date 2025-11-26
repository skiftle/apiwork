# frozen_string_literal: true

module Apiwork
  module Adapter
    class Base
      def build_global_descriptors(builder, schema_data)
        raise NotImplementedError
      end

      def build_contract(contract_class, schema_class, actions:)
        raise NotImplementedError
      end

      def render_collection(collection, schema_class, action_data)
        raise NotImplementedError
      end

      def render_record(record, schema_class, action_data)
        raise NotImplementedError
      end

      def render_error(issues, action_data)
        raise NotImplementedError
      end
    end
  end
end
