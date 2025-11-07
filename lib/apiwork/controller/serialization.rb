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

      # Get action output parser for current action
      #
      # @return [Contract::Parser] Parser instance for output
      def action_output
        @action_output ||= begin
          contract = find_contract&.new
          return nil unless contract

          Contract::Parser.new(contract, :output, action_name, context: build_schema_context)
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
                   Contract::Parser.new(contract.new, :output, action_name, context: build_schema_context)
                 else
                   action_output
                 end

        raise ConfigurationError, "No contract found for #{self.class.name}" unless output

        # Transform meta keys before building response
        transformed_meta = output.transform_meta_keys(meta)

        # Build response using ResponseRenderer
        response_hash = build_response(resource_or_collection, output, transformed_meta)

        # Validate response using Parser
        result = output.perform(response_hash)

        render json: result.data, status: status || determine_status(resource_or_collection)
      end

      private

      # Build response hash using ResponseRenderer
      #
      # @param resource_or_collection [Object] Resource or collection to render
      # @param output [Contract::Parser] Parser instance for output
      # @param meta [Hash] Transformed meta information
      # @return [Hash] Complete response hash
      def build_response(resource_or_collection, output, meta)
        query_params = extract_query_params_for_output

        ResponseRenderer.new(
          controller: self,
          action_definition: output.action_definition,
          schema_class: output.schema_class,
          meta: meta
        ).perform(resource_or_collection, query_params: query_params)
      end

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

        params = action_input.data || {}
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
