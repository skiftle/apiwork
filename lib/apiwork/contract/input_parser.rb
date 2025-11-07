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
        return Result.new(params: {}, errors: validated[:errors], schema_class: @schema_class) if validated[:errors].any?

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

      # Transform params (nested attributes for create/update actions)
      def transform_params(params)
        return params unless @schema_class
        return params unless [:create, :update].include?(@action)

        # Get root key from schema
        root_key_obj = @schema_class.root_key
        singular_key = root_key_obj.singular.to_sym

        # If params have root key, unwrap, transform, and rewrap
        if params.key?(singular_key)
          inner_params = params[singular_key]
          transformed_inner = NestedAttributesTransformer.new(@schema_class, @action).transform(inner_params)
          params.merge(singular_key => transformed_inner)
        else
          # No root key, transform directly
          NestedAttributesTransformer.new(@schema_class, @action).transform(params)
        end
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
