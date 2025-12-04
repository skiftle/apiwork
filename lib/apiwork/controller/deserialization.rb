# frozen_string_literal: true

module Apiwork
  module Controller
    module Deserialization
      extend ActiveSupport::Concern

      included do
        before_action :validate_contract
      end

      class_methods do
        def skip_contract_validation!(**options)
          skip_before_action :validate_contract, **options
        end
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
        return unless resource_metadata
        return if contract.valid?

        raise ContractError, contract.issues
      end

      def transformed_query_parameters
        parameters = request.query_parameters.deep_symbolize_keys
        parameters = api_class.transform_request(parameters)
        adapter.transform_request(parameters)
      end

      def transformed_body_parameters
        parameters = request.request_parameters.deep_symbolize_keys
        parameters = api_class.transform_request(parameters)
        adapter.transform_request(parameters)
      end
    end
  end
end
