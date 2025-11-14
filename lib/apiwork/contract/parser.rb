# frozen_string_literal: true

module Apiwork
  module Contract
    # Unified parser for validating and transforming contract data
    #
    # Handles both input (request params) and output (response data) validation
    # and transformation in a single, consistent API.
    #
    # Combines validation and transformation in a single step (Zod-like API):
    # 1. Coerces types (string → Integer, Date, etc)
    # 2. Validates data against contract's definition (input_definition or output_definition)
    # 3. Transforms validated data (nested attributes, etc.)
    #
    # Usage:
    #   # Input parsing (with coercion enabled to convert strings from HTTP to proper types)
    #   parser = Contract::Parser.new(contract_class, :input, :create, coerce: true)
    #   result = parser.perform(params)
    #   if result.valid?
    #     Model.create(result[:model])
    #   end
    #
    #   # Output parsing (without coercion - validates types as-is from Ruby code)
    #   parser = Contract::Parser.new(contract_class, :output, :index, coerce: false, context: { current_user: user })
    #   result = parser.perform(response_hash)
    #   if result.valid?
    #     render json: result.data
    #   end
    #
    class Parser
      include Coercion
      include Transformation
      include Validation

      attr_reader :contract_class, :action, :direction, :context

      def initialize(contract_class, direction, action, **options)
        @contract_class = contract_class
        @direction = direction.to_sym
        @action = action.to_sym
        @coerce = options.fetch(:coerce, false)
        @context = options[:context] || {}

        validate_direction!
      end

      # Get action definition for current action
      def action_definition
        @action_definition ||= contract_class.action_definition(action)
      end

      # Get schema class from action definition
      def schema_class
        @schema_class ||= action_definition&.schema_class
      end

      def perform(data)
        # Step 1: Coerce types (only for input - output already has correct types)
        coerced_data = @coerce ? coerce(data) : data

        # Step 2: Validate coerced data
        validated = validate(coerced_data)

        # Step 3: Handle errors based on direction
        return handle_validation_errors(data, validated[:issues]) if validated[:issues].any?

        # Step 4: Transform validated data
        transformed_data = transform(validated[:params])

        # Step 5: Build result
        build_result(transformed_data, [])
      end

      private

      # Validate direction parameter
      def validate_direction!
        return if %i[input output].include?(@direction)

        raise ArgumentError, "direction must be :input or :output, got #{@direction.inspect}"
      end

      # Get the appropriate definition based on direction
      def definition
        @definition ||= case direction
                        when :input
                          action_definition&.merged_input_definition
                        when :output
                          action_definition&.merged_output_definition
                        end
      end

      # Build result object with direction-specific attributes
      def build_result(data, errors)
        Result.new(data, errors)
      end
    end
  end
end
