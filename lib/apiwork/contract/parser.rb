# frozen_string_literal: true

module Apiwork
  module Contract
    # Unified parser for validating and transforming contract data
    #
    # Handles both input (request params) and output (response data) validation
    # and transformation in a single, consistent API.
    #
    # Combines validation and transformation in a single step (Zod-like API):
    # 1. Validates data against contract's definition (input_definition or output_definition)
    # 2. Transforms validated data (nested attributes, etc.)
    #
    # Usage:
    #   # Input parsing
    #   parser = Contract::Parser.new(contract, :input, :create)
    #   result = parser.perform(params)
    #   if result.valid?
    #     Model.create(result[:model])
    #   end
    #
    #   # Output parsing
    #   parser = Contract::Parser.new(contract, :output, :index, context: { current_user: user })
    #   result = parser.perform(response_hash)
    #   if result.valid?
    #     render json: result.response
    #   end
    #
    class Parser
      attr_reader :contract, :action, :direction, :action_definition, :schema_class, :context

      def initialize(contract, direction, action, **options)
        @contract = contract
        @direction = direction.to_sym
        @action = action.to_sym
        @context = options[:context] || {}
        @action_definition = contract.class.action_definition(@action)
        @schema_class = @action_definition&.schema_class

        validate_direction!
      end

      # Parse (validate + transform) data
      #
      # @param data [Hash] Data to parse (params for input, response_hash for output)
      # @return [Result] Result object with parsed data and errors
      def perform(data)
        # Step 1: Validate data against definition
        validated = validate(data)

        # Step 2: Handle errors based on direction
        if validated[:errors].any?
          return handle_validation_errors(data, validated[:errors])
        end

        # Step 3: Transform validated data
        transformed_data = transform(validated[:params])

        # Step 4: Build result
        build_result(transformed_data, [])
      end

      # Transform meta keys to match schema's key transform
      # Only available for output direction
      #
      # @param meta [Hash] Meta hash to transform
      # @return [Hash] Transformed meta hash
      def transform_meta_keys(meta)
        unless @direction == :output
          raise ArgumentError, "transform_meta_keys only available for output direction"
        end

        return meta unless meta.present? && @schema_class

        meta_key_transform = @schema_class.serialize_key_transform
        Apiwork::Transform::Case.hash(meta, meta_key_transform)
      end

      private

      # Validate direction parameter
      def validate_direction!
        unless %i[input output].include?(@direction)
          raise ArgumentError, "direction must be :input or :output, got #{@direction.inspect}"
        end
      end

      # Get the appropriate definition based on direction
      def definition
        @definition ||= case @direction
                        when :input
                          @action_definition&.input_definition
                        when :output
                          @action_definition&.merged_output_definition
                        end
      end

      # Validate data using definition
      def validate(data)
        return { params: data, errors: [] } unless definition

        definition.validate(data) || { params: data, errors: [] }
      end

      # Handle validation errors based on direction
      #
      # Input: Return empty data (invalid input should not be processed)
      # Output: Return original data (validation failure indicates a bug in response building,
      #         but we still return the response to avoid breaking the API)
      def handle_validation_errors(original_data, errors)
        case @direction
        when :input
          # Input: Never return invalid params
          build_result({}, errors)
        when :output
          # Output: Return response even if invalid (validation serves as warning)
          # This allows debugging of response structure issues without breaking API
          build_result(original_data, errors)
        end
      end

      # Transform data based on direction
      def transform(data)
        return data unless definition

        case @direction
        when :input
          apply_transformations(data, definition)
        when :output
          # For now, no transformations on output
          # Infrastructure ready if we add 'as:' support to output definitions
          data
        end
      end

      # Recursively apply 'as:' transformations from definition
      # Used for input direction to transform params (e.g., comments → comments_attributes)
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

      # Build result object with direction-specific attributes
      def build_result(data, errors)
        Result.new(data, errors, @direction, schema_class: @schema_class)
      end

      # Result object wrapping parsed data
      #
      # Provides a unified interface for both input and output parsing results.
      # The main data is stored in @data and can be accessed via:
      # - result.data (direction-agnostic)
      # - result[:key] (hash-like accessor)
      # - result.params (input direction only, for compatibility)
      # - result.response (output direction only, for compatibility)
      #
      class Result
        attr_reader :data, :errors, :direction

        def initialize(data, errors, direction, schema_class: nil)
          @data = data
          @errors = errors
          @direction = direction
          @schema_class = schema_class
        end

        # Hash-like accessor for convenient data access
        #
        # @example
        #   result[:client]  # → { name: "Test", ... }
        #
        # @param key [Symbol, String] The key to access
        # @return [Object] The value at the key
        def [](key)
          @data[key]
        end

        # Alias for input direction (backward compatibility)
        #
        # @return [Hash] The parsed params
        def params
          @data
        end

        # Alias for output direction (backward compatibility)
        #
        # @return [Hash] The validated response
        def response
          @data
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
