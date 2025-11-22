# frozen_string_literal: true

module Apiwork
  module Controller
    module Serialization
      extend ActiveSupport::Concern

      def respond_with(resource_or_collection, meta: {}, status: nil)
        action_definition = current_contract.action_definition(action_name)
        schema_class = action_definition&.schema_class
        formatted_meta = current_contract.format_keys(meta, :output)

        responder = Responder.new(
          controller: self,
          action_definition: action_definition,
          schema_class: schema_class,
          meta: formatted_meta
        )

        response = responder.perform(resource_or_collection, query_params: action_input.data)

        skip_validation = request.delete? && action_definition&.schema_class.present?
        unless skip_validation
          result = current_contract.parse(response, :output, action_name, coerce: false, context: context)
          raise ContractError, result.issues if result.invalid?
        end

        render json: response, status: status || action_name.to_sym == :create ? :created : :ok
      end

      private

      def context
        {}
      end
    end
  end
end
