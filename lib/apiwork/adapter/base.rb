# frozen_string_literal: true

module Apiwork
  module Adapter
    class Base
      extend Registrable
      include Configurable

      def register_api_types(type_registrar, schema_data)
        raise NotImplementedError
      end

      def register_contract_types(type_registrar, schema_class, actions:)
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

      def transform_request(hash, schema_class)
        hash
      end

      def transform_response(hash, schema_class)
        hash
      end
    end
  end
end
