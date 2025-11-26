# frozen_string_literal: true

module Apiwork
  module Controller
    module Serialization
      extend ActiveSupport::Concern

      def respond_with(resource_or_collection, meta: {}, status: nil)
        serializer = ResponseSerializer.new(current_contract, action_name, request.method_symbol)

        response = serializer.perform(
          resource_or_collection,
          request: action_request,
          meta: meta,
          context: context
        )

        skip_validation = request.delete? && serializer.schema_class.present?
        unless skip_validation
          result = current_contract.parse(response, :response_body, action_name, coerce: false, context: context)
          raise ContractError, result.issues if result.invalid?
        end

        render json: response, status: status || action_name.to_sym == :create ? :created : :ok
      end

      def render_error(issues, status: :bad_request)
        issues_array = Array(issues)
        response = adapter.render_error(issues_array, adapter_context)
        render json: response, status: status
      end

      private

      def adapter
        @adapter ||= current_contract.api_class.adapter
      end

      def adapter_context
        @adapter_context ||= Adapter::Context.new(
          action_name: action_name,
          method: request.method_symbol,
          actions: {}
        )
      end

      def context
        {}
      end
    end
  end
end
