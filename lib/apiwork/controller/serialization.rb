# frozen_string_literal: true

module Apiwork
  module Controller
    module Serialization
      extend ActiveSupport::Concern

      def respond_with(resource_or_collection, meta: {}, status: nil)
        output_parser = Contract::Parser.new(current_contract, :output, action_name, coerce: false, context: context)

        responder = Responder.new(
          controller: self,
          action_definition: output_parser.action_definition,
          schema_class: output_parser.schema_class,
          meta: output_parser.transform_meta_keys(meta)
        )

        response = responder.perform(resource_or_collection, query_params: action_input.data)

        result = output_parser.perform(response)
        raise ContractError, result.issues if result.invalid?

        render json: response, status: status || :ok
      end

      private

      def context
        {}
      end
    end
  end
end
