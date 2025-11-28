# frozen_string_literal: true

module Apiwork
  module Controller
    module Deserialization
      extend ActiveSupport::Concern

      included do
        before_action :validate_input
      end

      class_methods do
        def skip_validate_input!(only: nil, except: nil)
          skip_before_action :validate_input, only: only, except: except
        end
      end

      def contract
        @contract ||= contract_class.new(
          query: transformed_query_params,
          body: transformed_body_params,
          action: action_name
        )
      end

      def query
        contract.query
      end

      def body
        contract.body
      end

      private

      def validate_input
        return if contract.valid?

        raise ContractError, contract.issues
      end

      def transformed_query_params
        data = request.query_parameters.deep_symbolize_keys
        schema_class = contract_class.action_definition(action_name)&.schema_class
        schema_class ? adapter.transform_request(data, schema_class) : data
      end

      def transformed_body_params
        data = request.request_parameters.deep_symbolize_keys
        schema_class = contract_class.action_definition(action_name)&.schema_class
        schema_class ? adapter.transform_request(data, schema_class) : data
      end
    end
  end
end
