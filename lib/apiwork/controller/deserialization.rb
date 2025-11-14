# frozen_string_literal: true

module Apiwork
  module Controller
    module Deserialization
      extend ActiveSupport::Concern

      included do
        before_action :validate_input
      end

      class_methods do
        def skip_validate_input!(only: nil, except: nil)
          skip_before_action :validate_input, only: only, except: except
        end
      end

      def action_input
        @action_input ||= begin
          return Contract::Parser::Result.new({}, [], :input, schema_class: nil) unless current_contract

          request_params = parse_request_params(request)

          # Parse: validate + transform in one step
          Contract::Parser.new(current_contract, :input, action_name).perform(request_params)
        end
      end

      private

      def validate_input
        return if action_input.valid?

        raise ContractError, action_input.issues
      end

      def parse_request_params(request)
        query = parse_query_params(request)
        body = parse_body_params(request)
        query.merge(body)
      end

      # Parse query parameters from URL
      def parse_query_params(request)
        return {} unless request.query_parameters

        params = request.query_parameters
        params = Transform::Case.hash(params, key_transform)
        params.deep_symbolize_keys
      end

      # Parse body parameters from POST/PATCH/PUT
      def parse_body_params(request)
        return {} unless request.post? || request.patch? || request.put?

        body_hash = request.request_parameters.except(:controller, :action, :format)
        body_hash = Transform::Case.hash(body_hash, key_transform)
        body_hash.deep_symbolize_keys
      end

      # Get key transform from configuration
      def key_transform
        Apiwork.configuration.deserialize_key_transform
      end
    end
  end
end
