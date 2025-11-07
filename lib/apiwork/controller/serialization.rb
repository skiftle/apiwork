# frozen_string_literal: true

module Apiwork
  module Controller
    # Handles schema serialization and response building
    #
    # Provides:
    # - respond_with - Unified response builder for all actions
    # - action_output - ActionOutput instance for current action
    #
    module Serialization
      extend ActiveSupport::Concern

      # Get action output processor for current action
      #
      # @return [ActionOutput] ActionOutput instance
      def action_output
        @action_output ||= begin
          contract = find_contract&.new
          return nil unless contract

          ActionOutput.new(
            contract: contract,
            action: action_name,
            context: build_schema_context,
            request_method: request.method
          )
        end
      end

      # Unified response builder for all actions
      #
      # @param resource_or_collection [Object] Resource or collection to render
      # @param meta [Hash] Additional meta information
      # @param contract [Class] Optional contract class override
      # @param status [Symbol] Optional HTTP status override
      def respond_with(resource_or_collection, meta: {}, contract: nil, status: nil)
        output = if contract
                   ActionOutput.new(
                     contract: contract.new,
                     action: action_name,
                     context: build_schema_context,
                     request_method: request.method
                   )
                 else
                   action_output
                 end

        raise ConfigurationError, "No contract found for #{self.class.name}" unless output

        # Extract query params from action_input for auto-querying
        query_params = extract_query_params_for_output

        result = output.perform(resource_or_collection, meta: meta, query_params: query_params)
        render json: result.response, status: status || determine_status(resource_or_collection)
      end

      private

      # Find contract for current controller
      def find_contract
        action_definition = find_action_definition
        action_definition&.contract_class
      end

      # Find action definition for current action
      def find_action_definition
        Contract::Resolver.resolve(self.class, action_name.to_sym, metadata: find_action_metadata)
      end

      # Extract query params for ActionOutput
      def extract_query_params_for_output
        return {} unless action_input

        params = action_input.params || {}
        {
          filter: params[:filter],
          sort: params[:sort],
          page: params[:page],
          include: params[:include]
        }.compact
      end

      # Determine HTTP status based on resource state
      def determine_status(resource_or_collection)
        if resource_or_collection.respond_to?(:errors) && resource_or_collection.errors.any?
          :unprocessable_content
        elsif request.delete?
          :ok
        elsif request.post?
          :created
        else
          :ok
        end
      end

      def build_schema_context
        {}
      end
    end
  end
end
