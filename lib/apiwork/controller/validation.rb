# frozen_string_literal: true

module Apiwork
  module Controller
    module Validation
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
          contract = find_contract&.new
          return Contract::Parser::Result.new({}, [], :input, schema_class: nil) unless contract

          raw_params = parse_request_params(request)

          # Parse: validate + transform in one step
          Contract::Parser.new(contract, :input, action_name).perform(raw_params)
        end
      end

      # Input validation using contracts (before_action)
      def validate_input
        return unless action_input.invalid?

        # Convert ValidationError objects to StructuredError format
        structured_errors = action_input.errors.map do |error|
          StructuredError.new(
            code: error.code,
            detail: error.detail,
            path: error.path,
            **error.meta
          )
        end

        raise StructuredErrorCollection, structured_errors
      end

      private

      # Find contract for current controller
      def find_contract
        action_definition = current_action_definition
        action_definition&.contract_class
      end

      # Get current action definition for this action
      def current_action_definition
        @current_action_definition ||= Contract::Resolver.resolve(controller_class: self.class, action_name: action_name.to_sym)
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
        params = params.deep_symbolize_keys

        # Normalize hash with numeric keys to array (for filter/sort/include params)
        normalize_indexed_hashes(params)
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

      # Recursively normalize hashes with numeric string keys to arrays
      def normalize_indexed_hashes(params)
        return params unless params.is_a?(Hash)

        params.transform_values do |value|
          normalize_indexed_value(value)
        end
      end

      # Normalize a single value (recursive)
      def normalize_indexed_value(value)
        return value unless value.is_a?(Hash) || value.is_a?(Array)
        return value.map { |v| normalize_indexed_value(v) } if value.is_a?(Array)

        # Handle hash: check if numeric-indexed or regular nested hash
        return convert_indexed_hash_to_array(value) if indexed_hash?(value)

        normalize_indexed_hashes(value)
      end

      # Convert indexed hash to array, preserving numeric order
      def convert_indexed_hash_to_array(hash)
        hash.keys.sort_by { |k| k.to_s.to_i }.map { |key| normalize_indexed_value(hash[key]) }
      end

      # Check if hash has only numeric string keys
      def indexed_hash?(hash)
        return false if hash.empty?

        hash.keys.all? { |k| k.to_s =~ /^\d+$/ }
      end
    end
  end
end
