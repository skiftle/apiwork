# frozen_string_literal: true

module Apiwork
  module Controller
    module Deserialization
      extend ActiveSupport::Concern

      included do
        before_action :validate_contract
      end

      def contract
        @contract ||= contract_class.new(
          query: transformed_query_parameters,
          body: transformed_body_parameters,
          action: action_name
        )
      end

      private

      def validate_contract
        return if contract.valid?

        raise ContractError, contract.issues
      end

      def transformed_query_parameters
        parameters = request.query_parameters.deep_symbolize_keys
        schema_class = contract_class.schema_class
        schema_class ? adapter.transform_request(parameters, schema_class) : parameters
      end

      def transformed_body_parameters
        parameters = request.request_parameters.deep_symbolize_keys
        schema_class = contract_class.schema_class
        schema_class ? adapter.transform_request(parameters, schema_class) : parameters
      end
    end
  end
end
