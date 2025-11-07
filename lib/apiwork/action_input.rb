# frozen_string_literal: true

module Apiwork
  # Processes and validates input parameters for a contract action
  #
  # Handles:
  # - Input validation against contract's input_definition
  # - Nested attributes transformation for Rails (comments → comments_attributes)
  #
  # Usage:
  #   input = ActionInput.new(contract: MyContract.new, action: :create)
  #   result = input.perform(params)
  #
  #   if result.valid?
  #     Model.create(result[:model])
  #   end
  #
  class ActionInput
    attr_reader :contract, :action, :action_definition, :schema_class, :context

    def initialize(contract:, action:, **options)
      @contract = contract
      @action = action.to_sym
      @context = options[:context] || {}
      @action_definition = contract.class.action_definition(@action)
      @schema_class = @action_definition&.schema_class
    end

    # Process and validate input parameters
    #
    # @param params [Hash] Input parameters to validate and process
    # @return [Result] Result object with validated params and errors
    def perform(params)
      # Step 1: Validate params against input_definition
      validated = validate_params(params)
      return Result.new(params: {}, errors: validated[:errors], schema_class: @schema_class) if validated[:errors].any?

      # Step 2: Transform nested attributes for Rails (comments → comments_attributes)
      transformed_params = transform_nested_attributes(validated[:params])

      Result.new(params: transformed_params, errors: [], schema_class: @schema_class)
    end

    private

    # Validate params using action's input_definition
    def validate_params(params)
      return { params: params, errors: [] } unless @action_definition&.input_definition

      @action_definition.input_definition.validate(params) || { params: params, errors: [] }
    end

    # Transform nested attributes for create/update actions
    def transform_nested_attributes(params)
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

    # Result object wrapping validated parameters
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
