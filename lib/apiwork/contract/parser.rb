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
    #     render json: result.data
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

      # Parse (coerce + validate + transform) data
      #
      # @param data [Hash] Data to parse (params for input, response_hash for output)
      # @return [Result] Result object with parsed data and errors
      def perform(data)
        # Step 1: Coerce types (string → Integer, Date, etc)
        coerced_data = coerce(data)

        # Step 2: Validate coerced data
        validated = validate(coerced_data)

        # Step 3: Handle errors based on direction
        return handle_validation_errors(data, validated[:errors]) if validated[:errors].any?

        # Step 4: Transform validated data
        transformed_data = transform(validated[:params])

        # Step 5: Build result
        build_result(transformed_data, [])
      end

      # Transform meta keys to match schema's key transform
      # Only available for output direction
      #
      # @param meta [Hash] Meta hash to transform
      # @return [Hash] Transformed meta hash
      def transform_meta_keys(meta)
        raise ArgumentError, 'transform_meta_keys only available for output direction' unless @direction == :output

        return meta unless meta.present? && @schema_class

        meta_key_transform = @schema_class.serialize_key_transform
        Apiwork::Transform::Case.hash(meta, meta_key_transform)
      end

      private

      # Validate direction parameter
      def validate_direction!
        return if %i[input output].include?(@direction)

        raise ArgumentError, "direction must be :input or :output, got #{@direction.inspect}"
      end

      # Get the appropriate definition based on direction
      def definition
        @definition ||= case @direction
                        when :input
                          @action_definition&.merged_input_definition
                        when :output
                          @action_definition&.merged_output_definition
                        end
      end

      # Coerce data types before validation
      def coerce(data)
        return data unless data.is_a?(Hash)
        return data unless definition

        coerce_hash(data, definition)
      end

      # Validate data using definition
      def validate(data)
        return { params: data, errors: [] } unless definition

        definition.validate(data) || { params: data, errors: [] }
      end

      # Recursively coerce hash based on definition
      def coerce_hash(hash, definition)
        coerced = hash.dup

        definition.params.each do |name, param_options|
          next unless coerced.key?(name)

          value = coerced[name]
          coerced[name] = coerce_value(value, param_options, definition)
        end

        coerced
      end

      # Coerce single value based on param options
      def coerce_value(value, param_options, _definition)
        type = param_options[:type]

        # Handle union types
        return coerce_union(value, param_options[:union]) if type == :union

        # Handle arrays
        return coerce_array(value, param_options) if type == :array && value.is_a?(Array)

        # Handle nested objects
        return coerce_hash(value, param_options[:nested]) if param_options[:nested] && value.is_a?(Hash)

        # Handle primitive types
        if Coercer.can_coerce?(type)
          coerced = Coercer.coerce(value, type)
          return coerced unless coerced.nil?
        end

        value
      end

      # Coerce array elements
      def coerce_array(array, param_options)
        array.map do |item|
          if param_options[:nested] && item.is_a?(Hash)
            # Nested object in array
            coerce_hash(item, param_options[:nested])
          elsif param_options[:of] && Coercer.can_coerce?(param_options[:of])
            # Simple typed array
            coerced = Coercer.coerce(item, param_options[:of])
            coerced.nil? ? item : coerced
          else
            item
          end
        end
      end

      # Coerce union - try each variant
      def coerce_union(value, union_def)
        # Special case: boolean unions need coercion for query params
        if union_def.variants.any? { |variant| variant[:type] == :boolean }
          coerced = Coercer.coerce(value, :boolean)
          return coerced unless coerced.nil?
        end

        # For other unions, return original (validation will determine correct variant)
        value
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
        Result.new(data, errors)
      end

      # Result object wrapping parsed data
      #
      # Provides a unified interface for both input and output parsing results.
      # The main data is stored in @data and can be accessed via:
      # - result.data (direction-agnostic)
      # - result[:key] (hash-like accessor)
      # - result.params (input direction only, for compatibility)
      #
      class Result
        attr_reader :data, :errors

        def initialize(data, errors)
          @data = data
          @errors = errors
        end

        def [](key)
          @data[key]
        end

        def params
          @data
        end

        def valid?
          errors.empty?
        end

        def invalid?
          errors.any?
        end
      end
    end
  end
end
