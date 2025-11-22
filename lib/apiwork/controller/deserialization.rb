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
          data = transform_keys(data, key_transform)
          data = ParamsNormalizer.call(data)

          current_contract.parse(data, :query, action_name, coerce: true)
        end
      end

      def action_body
        @action_body ||= begin
          data = request.request_parameters.deep_symbolize_keys
          data = transform_keys(data, key_transform)
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

      def key_transform
        Configuration::Resolver.resolve(:input_key_format, contract_class: current_contract)
      end

      def transform_keys(hash, strategy)
        case strategy
        when :camel
          hash.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
        when :underscore
          hash.deep_transform_keys { |key| key.to_s.underscore.to_sym }
        else
          hash
        end
      end
    end
  end
end
