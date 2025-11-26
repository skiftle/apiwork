# frozen_string_literal: true

module Apiwork
  module Controller
    module Deserialization
      extend ActiveSupport::Concern

      Result = Contract::Parser::Result

      included do
        before_action :validate_input
      end

      class_methods do
        def skip_validate_input!(only: nil, except: nil)
          skip_before_action :validate_input, only: only, except: except
        end
      end

      def action_query
        @action_query ||= begin
          data = request.query_parameters.deep_symbolize_keys
          data = adapter.transform_request(data, current_contract.api_class)
          data = ParamsNormalizer.call(data)

          current_contract.parse(data, :query, action_name, coerce: true)
        end
      end

      def action_body
        @action_body ||= begin
          data = request.request_parameters.deep_symbolize_keys
          data = adapter.transform_request(data, current_contract.api_class)
          data = ParamsNormalizer.call(data)

          current_contract.parse(data, :body, action_name, coerce: true)
        end
      end

      def action_request
        @action_request ||= begin
          query_result = action_query
          body_result = action_body

          all_issues = query_result.issues + body_result.issues
          merged_data = (query_result.data || {}).merge(body_result.data || {})

          Result.new(merged_data, all_issues)
        end
      end

      private

      def validate_input
        return if action_request.valid?

        raise ContractError, action_request.issues
      end

      def adapter
        @adapter ||= current_contract.api_class.adapter
      end
    end
  end
end
