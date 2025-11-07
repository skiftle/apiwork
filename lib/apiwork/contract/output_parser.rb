# frozen_string_literal: true

module Apiwork
  module Contract
    # Parses and validates output responses for a contract action
    #
    # Combines validation and transformation in a single step (Zod-like API):
    # 1. Validates response against contract's output_definition
    # 2. Transforms validated response (if needed)
    #
    # Usage:
    #   parser = Contract::OutputParser.new(contract: contract, action: :index)
    #   result = parser.perform(response_hash)
    #
    #   if result.valid?
    #     render json: result.response
    #   end
    #
    class OutputParser
      attr_reader :contract, :action, :action_definition, :schema_class, :context

      def initialize(contract:, action:, **options)
        @contract = contract
        @action = action.to_sym
        @context = options[:context] || {}
        @action_definition = contract.class.action_definition(@action)
        @schema_class = @action_definition&.schema_class
      end

      # Parse (validate + transform) output response
      #
      # @param response_hash [Hash] Complete response hash to validate
      # @return [Result] Result object with validated response and errors
      def perform(response_hash)
        # Step 1: Validate response against output_definition
        validated = validate_response(response_hash)

        # Return response even if validation fails (errors are tracked in Result)
        # This allows the response to be returned while logging validation issues
        transformed_response = if validated[:errors].any?
                                 response_hash # Return original if validation failed
                               else
                                 transform_response(validated[:params])
                               end

        Result.new(response: transformed_response, errors: validated[:errors])
      end

      # Transform meta keys to match schema's key transform
      # Called from Controller before building response
      def transform_meta_keys(meta)
        return meta unless meta.present? && @schema_class

        meta_key_transform = @schema_class.serialize_key_transform
        Apiwork::Transform::Case.hash(meta, meta_key_transform)
      end

      private

      # Validate response using action's output_definition
      def validate_response(response_hash)
        merged_output = @action_definition&.merged_output_definition
        return { params: response_hash, errors: [] } unless merged_output

        # Use Definition#validate for full validation
        result = merged_output.validate(response_hash)
        result || { params: response_hash, errors: [] }
      end

      # Transform response based on 'as:' options in output_definition
      # (Future: mirror InputParser's apply_transformations if needed)
      def transform_response(response_hash)
        return response_hash unless @action_definition&.merged_output_definition

        # For now, no transformations on output
        # But infrastructure ready if we add 'as:' support to output definitions
        response_hash
      end

      # Result object wrapping validated response
      class Result
        attr_reader :response, :errors

        def initialize(response:, errors:)
          @response = response
          @errors = errors
        end

        # Check if validation succeeded
        #
        # @return [Boolean] true if no errors
        def valid?
          errors.empty?
        end

        # Check if validation failed
        #
        # @return [Boolean] true if errors present
        def invalid?
          errors.any?
        end
      end
    end
  end
end
