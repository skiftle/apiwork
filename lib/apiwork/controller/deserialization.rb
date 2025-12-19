# frozen_string_literal: true

module Apiwork
  module Controller
    # @api private
    module Deserialization
      extend ActiveSupport::Concern

      included do
        wrap_parameters false
        before_action :validate_contract
      end

      class_methods do
        # Skips contract validation for specified actions.
        #
        # Use this when certain actions don't need request validation,
        # such as health checks or legacy endpoints.
        #
        # @param options [Hash] options passed to skip_before_action
        # @option options [Array<Symbol>] :only skip only for these actions
        # @option options [Array<Symbol>] :except skip for all except these
        #
        # @example Skip for specific actions
        #   class HealthController < ApplicationController
        #     skip_contract_validation! only: [:ping, :status]
        #   end
        #
        # @example Skip for all actions
        #   class LegacyController < ApplicationController
        #     skip_contract_validation!
        #   end
        def skip_contract_validation!(**options)
          skip_before_action :validate_contract, **options
        end
      end

      # Returns the parsed and validated request contract.
      #
      # The contract contains parsed query parameters and request body,
      # with type coercion applied. Access parameters via `contract.query`
      # and `contract.body`.
      #
      # @return [Apiwork::Contract::Base] the contract instance
      #
      # @example Access parsed parameters
      #   def create
      #     invoice = Invoice.new(contract.body)
      #     # contract.body contains validated, coerced params
      #   end
      #
      # @example Check for specific parameters
      #   def index
      #     if contract.query[:include]
      #       # handle include parameter
      #     end
      #   end
      def contract
        @contract ||= contract_class.new(
          query: transformed_query_parameters,
          body: transformed_body_parameters,
          action_name: action_name,
          coerce: true
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
