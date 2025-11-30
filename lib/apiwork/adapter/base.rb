# frozen_string_literal: true

module Apiwork
  module Adapter
    class Base
      include Registrable
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

      def build_api_type_registrar(api_class)
        ApiTypeRegistrar.new(api_class)
      end

      def build_contract_type_registrar(contract_class)
        ContractTypeRegistrar.new(contract_class)
      end

      def build_schema_data(schemas, has_resources: false, has_index_actions: false)
        SchemaData.new(schemas, has_resources:, has_index_actions:)
      end
    end
  end
end
