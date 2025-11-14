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

      QUERY_PARAMS = %i[filter sort page include].freeze

      def action_output
        @action_output ||= begin
          contract = current_contract&.new
          return nil unless contract

          Contract::Parser.new(contract, :output, action_name, context: build_schema_context)
        end
      end

      def respond_with(resource_or_collection, meta: {}, contract: nil, status: nil)
        output = resolve_output_parser(contract)
        raise ConfigurationError, "No contract found for #{self.class.name}" unless output

        transformed_meta = transform_meta(output, meta)
        response_hash = build_response(resource_or_collection, output, transformed_meta)
        validated_response = validate_response(output, response_hash)

        render json: validated_response.data, status: status || :ok
      end

      private

      def resolve_output_parser(contract)
        if contract
          Contract::Parser.new(contract.new, :output, action_name, context: build_schema_context)
        else
          action_output
        end
      end

      def transform_meta(output, meta)
        output.transform_meta_keys(meta)
      end

      def validate_response(output, response_hash)
        output.perform(response_hash)
      end

      def build_response(resource_or_collection, output, meta)
        query_params = extract_query_params_for_output

        Responder.new(
          controller: self,
          action_definition: output.action_definition,
          schema_class: output.schema_class,
          meta: meta
        ).perform(resource_or_collection, query_params: query_params)
      end

      def extract_query_params_for_output
        return {} unless action_input

        params = action_input.data || {}
        params.slice(*QUERY_PARAMS).compact
      end

      # Override in controller to provide custom schema context
      # @return [Hash] context hash passed to schema serialization
      def build_schema_context
        {}
      end
    end
  end
end
