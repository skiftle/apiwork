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

      def respond_with(resource_or_collection, meta: {}, status: nil)
        raise ConfigurationError, "No contract found for #{self.class.name}" unless current_contract

        output_parser = Contract::Parser.new(current_contract, :output, action_name, context: context)

        responder = Responder.new(
          controller: self,
          action_definition: output_parser.action_definition,
          schema_class: output_parser.schema_class,
          meta: output_parser.transform_meta_keys(meta)
        )

        validaed = responder.perform(resource_or_collection, query_params: action_input.data)

        validated_response = output_parser.perform(validaed)

        render json: validated_response.data, status: status || :ok
      end

      private

      # Override in controller to provide custom schema context
      # @return [Hash] context hash passed to schema serialization
      def context
        {}
      end
    end
  end
end
