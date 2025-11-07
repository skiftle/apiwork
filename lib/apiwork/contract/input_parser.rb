# frozen_string_literal: true

module Apiwork
  module Contract
    # Parses and validates input parameters for a contract action
    #
    # Combines validation and transformation in a single step (Zod-like API):
    # 1. Validates params against contract's input_definition
    # 2. Transforms validated params (nested attributes, etc.)
    #
    # Usage:
    #   parser = Contract::InputParser.new(contract: contract, action: :create)
    #   result = parser.perform(params)
    #
    #   if result.valid?
    #     Model.create(result[:model])
    #   end
    #
    class InputParser
      attr_reader :contract, :action, :action_definition, :schema_class, :context

      def initialize(contract:, action:, **options)
        @contract = contract
        @action = action.to_sym
        @context = options[:context] || {}
        @action_definition = contract.class.action_definition(@action)
        @schema_class = @action_definition&.schema_class
      end

      # Parse (validate + transform) input parameters
      #
      # @param params [Hash] Input parameters to parse
      # @return [Result] Result object with parsed params and errors
      def perform(params)
        # Step 1: Validate params against input_definition
        validated = validate_params(params)
        if validated[:errors].any?
          return Result.new(params: {}, errors: validated[:errors],
                            schema_class: @schema_class)
        end

        # Step 2: Transform validated params (nested attributes for Rails)
        transformed_params = transform_params(validated[:params])

        Result.new(params: transformed_params, errors: [], schema_class: @schema_class)
      end

      private

      # Validate params using action's input_definition
      def validate_params(params)
        return { params: params, errors: [] } unless @action_definition&.input_definition

        @action_definition.input_definition.validate(params) || { params: params, errors: [] }
      end

      # Transform params based on 'as:' options in input_definition
      def transform_params(params)
        return params unless @action_definition&.input_definition

        apply_transformations(params, @action_definition.input_definition)
      end

      # Recursively apply 'as:' transformations from definition
      def apply_transformations(params, definition)
        return params unless params.is_a?(Hash)
        return params unless definition

        transformed = params.dup

        definition.params.each do |name, param_def|
          next unless transformed.key?(name)

          value = transformed[name]

          # If param has 'as:', rename the key
          if param_def[:as]
            transformed[param_def[:as]] = transformed.delete(name)
            name = param_def[:as] # Update name for nested processing
            value = transformed[name]
          end

          # Recursively transform nested params
          if param_def[:nested] && value.is_a?(Hash)
            transformed[name] = apply_transformations(value, param_def[:nested])
          elsif param_def[:nested] && value.is_a?(Array)
            # For arrays, transform each element
            transformed[name] = value.map do |item|
              item.is_a?(Hash) ? apply_transformations(item, param_def[:nested]) : item
            end
          end
        end

        transformed
      end

      # Result object wrapping parsed parameters
      class Result
        attr_reader :params, :errors

        def initialize(params:, errors:, schema_class: nil)
          @params = params
          @errors = errors
          @schema_class = schema_class
        end

        # Hash-like accessor for convenient parameter access
        #
        # @example
        #   result[:client]  # → { name: "Test", ... }
        #
        # @param key [Symbol, String] The key to access
        # @return [Object] The value at the key
        def [](key)
          @params[key]
        end

        # Check if parsing succeeded
        #
        # @return [Boolean] true if no errors
        def valid?
          errors.empty?
        end

        # Check if parsing failed
        #
        # @return [Boolean] true if errors present
        def invalid?
          errors.any?
        end
      end
    end
  end
end
