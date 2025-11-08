# frozen_string_literal: true

module Apiwork
  module Contract
    class Definition
      attr_reader :type, :params, :contract_class, :type_scope, :action_name, :direction, :parent_scope

      def initialize(type, contract_class, type_scope: :root, action_name: nil, parent_scope: nil)
        @type = type # :input or :output
        @direction = type # Alias for type (used by Descriptors::Registry.qualified_enum_name)
        @contract_class = contract_class
        @type_scope = type_scope
        @action_name = action_name
        @parent_scope = parent_scope
        @params = {}
      end

      # Serialize this definition to JSON-friendly hash
      # @return [Hash] Serialized parameter structure
      def as_json
        Serialization.serialize_definition(self)
      end

      # Define a custom type scoped to this input/output
      def type(name, &block)
        raise ArgumentError, 'Block required for custom type definition' unless block_given?

        # Delegate to contract class to store type in current scope
        @contract_class.type(name, &block)
      end

      # Define an enum scoped to this action/input/output
      # Enums defined here are available only within this definition's scope
      #
      # @param name [Symbol] Name of the enum (e.g., :priority)
      # @param values [Array] Array of allowed values (e.g., %w[low high])
      #
      # @example
      #   action :create do
      #     input do
      #       enum :priority, %w[low medium high]
      #       param :priority, type: :string, enum: :priority
      #     end
      #   end
      def enum(name, values)
        raise ArgumentError, 'Values array required for enum definition' unless values.is_a?(Array)

        # Register with Descriptors::Registry using this definition instance as scope
        # This creates definition-level scoping for the enum
        Descriptors::Registry.register_local_enum(self, name, values)
      end

      # Define a parameter
      # rubocop:disable Metrics/ParameterLists
      def param(name, type: :string, required: false, default: nil, enum: nil, of: nil, as: nil,
                discriminator: nil, value: nil, **options, &block)
        # rubocop:enable Metrics/ParameterLists
        # Resolve enum reference if it's a symbol
        resolved_enum = resolve_enum_value(enum)

        # Handle literal types
        if type == :literal
          # value can be false (boolean), so check if it was provided (not nil)
          raise ArgumentError, 'Literal type requires a value parameter' if value.nil? && !options.key?(:value)

          # Use value from named parameter or from options hash
          literal_value = value.nil? ? options[:value] : value

          @params[name] = {
            name: name,
            type: :literal,
            value: literal_value,
            required: required,
            default: default,
            as: as,
            **options.except(:value) # Remove :value from options to avoid duplication
          }
          return
        end

        # Validate discriminator usage
        raise ArgumentError, 'discriminator can only be used with type: :union' if discriminator && type != :union

        # Handle union types
        if type == :union
          raise ArgumentError, 'Union type requires a block with variant definitions' unless block_given?

          union_def = UnionDefinition.new(@contract_class, type_scope: @type_scope, discriminator: discriminator)
          union_def.instance_eval(&block)

          @params[name] = {
            name: name,
            type: :union,
            required: required,
            default: default,
            as: as,
            union: union_def,
            discriminator: discriminator,
            enum: resolved_enum, # Store resolved enum (values or reference)
            **options
          }
          return
        end

        # Check if type is a custom type (with scope resolution)
        custom_type_block = @contract_class.resolve_custom_type(type, @type_scope)

        # Check if we're already expanding this type (prevent infinite recursion)
        if custom_type_block
          expansion_key = [@contract_class.object_id, type]
          expanding_types = Thread.current[:apiwork_expanding_custom_types] ||= Set.new

          # If already expanding this type, treat it as a reference instead of expanding
          custom_type_block = nil if expanding_types.include?(expansion_key)
        end

        if custom_type_block
          # Custom type - expand it with recursion protection
          expansion_key = [@contract_class.object_id, type]
          expanding_types = Thread.current[:apiwork_expanding_custom_types] ||= Set.new
          expanding_types.add(expansion_key)

          begin
            shape_def = Definition.new(@type, @contract_class, type_scope: @type_scope)
            shape_def.instance_eval(&custom_type_block)

            # Apply additional block if provided (can extend custom type)
            shape_def.instance_eval(&block) if block_given?

            @params[name] = {
              name: name,
              type: :object, # Custom types are objects internally
              required: required,
              default: default,
              enum: resolved_enum, # Store resolved enum (values or reference)
              of: of,
              as: as,
              custom_type: type, # Track original custom type name
              shape: shape_def,
              **options
            }
          ensure
            expanding_types.delete(expansion_key)
          end
        else
          # Regular type
          @params[name] = {
            name: name,
            type: type,
            required: required,
            default: default,
            enum: resolved_enum, # Store resolved enum (values or reference)
            of: of,
            as: as,
            **options
          }

          # Handle shape param with do block
          if block_given?
            shape_def = Definition.new(@type, @contract_class)
            shape_def.instance_eval(&block)
            @params[name][:shape] = shape_def
          end
        end
      end

      # Validate data against this definition
      # @param data [Hash] Data to validate
      # @param options [Hash] Validation options
      # @option options [Integer] :max_depth Maximum nesting depth (default: 10)
      # @option options [Integer] :current_depth Current depth (for recursion)
      # @option options [Array] :path Current path (for error messages)
      def validate(data, options = {})
        max_depth = options.fetch(:max_depth, 10)
        current_depth = options.fetch(:current_depth, 0)
        path = options.fetch(:path, [])

        errors = []
        params = {}
        data = data.deep_symbolize_keys if data.respond_to?(:deep_symbolize_keys)

        # Check max depth
        return max_depth_error(current_depth, max_depth, path) if current_depth > max_depth

        # Validate each param
        @params.each do |name, param_options|
          param_result = validate_param(
            name,
            data[name],
            param_options,
            data,
            path,
            max_depth: max_depth,
            current_depth: current_depth
          )
          errors.concat(param_result[:errors])
          params[name] = param_result[:value] if param_result[:value_set]
        end

        # Check for unknown params
        errors.concat(check_unknown_params(data, path))

        { errors: errors, params: params }
      end

      private

      # Return max depth error
      def max_depth_error(current_depth, max_depth, path)
        errors = [ValidationError.max_depth_exceeded(
          depth: current_depth,
          max_depth: max_depth,
          path: path
        )]
        { errors: errors, params: {} }
      end

      # Validate a single parameter
      def validate_param(name, value, param_options, data, path, max_depth:, current_depth:)
        field_path = path + [name]

        # Check required
        required_error = validate_required(name, value, param_options, field_path)
        return { errors: [required_error], value_set: false } if required_error

        # Apply default if value is nil
        value = param_options[:default] if value.nil? && param_options[:default]

        # Check nullable constraint
        if data.key?(name) && value.nil? && param_options[:nullable] == false
          return { errors: [ValidationError.value_null(field: name, path: field_path)], value_set: false }
        end

        # Skip validation if value is nil and not required
        return { errors: [], value_set: false } if value.nil?

        # Validate enum
        enum_error = validate_enum_value(name, value, param_options[:enum], field_path)
        return { errors: [enum_error], value_set: false } if enum_error

        # Handle literal type validation
        if param_options[:type] == :literal
          expected = param_options[:value]
          unless value == expected
            error = ValidationError.new(
              code: :invalid_value,
              field: name,
              detail: "Value must be exactly #{expected.inspect}",
              path: field_path,
              expected: expected,
              actual: value
            )
            return { errors: [error], value_set: false }
          end
          return { errors: [], value: value, value_set: true }
        end

        # Handle union type validation
        if param_options[:type] == :union
          return validate_union_param(name, value, param_options, field_path, max_depth, current_depth)
        end

        # Validate type
        type_error = validate_type(name, value, param_options[:type], param_options[:shape], field_path)
        return { errors: [type_error], value_set: false } if type_error

        # Validate shape structures
        validate_shape_or_array(value, param_options, field_path, max_depth, current_depth)
      end

      # Check if required field is missing
      def validate_required(name, value, param_options, field_path)
        return nil unless param_options[:required]

        # Check if missing (matches Rails params.require behavior)
        # Special case: false is NOT blank for boolean fields
        is_missing = if param_options[:type] == :boolean
                       value.nil?
                     else
                       value.blank?
                     end

        return nil unless is_missing

        # For enum fields, return invalid_value error to show allowed values immediately
        if param_options[:enum].present?
          ValidationError.new(
            code: :invalid_value,
            field: name,
            detail: "Invalid value. Must be one of: #{param_options[:enum].join(', ')}",
            path: field_path,
            expected: param_options[:enum],
            actual: value
          )
        else
          ValidationError.field_missing(field: name, path: field_path)
        end
      end

      # Validate enum value
      def validate_enum_value(name, value, enum, field_path)
        return nil if enum.nil?

        # Extract values array from enum (handle both inline arrays and resolved hashes)
        enum_values = enum.is_a?(Hash) ? enum[:values] : enum

        return nil unless enum_values&.exclude?(value)

        ValidationError.new(
          code: :invalid_value,
          field: name,
          detail: "Invalid value. Must be one of: #{enum_values.join(', ')}",
          path: field_path,
          expected: enum_values,
          actual: value
        )
      end

      # Validate union type parameter
      def validate_union_param(name, value, param_options, field_path, max_depth, current_depth)
        union_error, union_value = validate_union(
          name,
          value,
          param_options[:union],
          field_path,
          max_depth: max_depth,
          current_depth: current_depth
        )
        if union_error
          { errors: [union_error], value_set: false }
        else
          { errors: [], value: union_value, value_set: true }
        end
      end

      # Validate shape object or array
      def validate_shape_or_array(value, param_options, field_path, max_depth, current_depth)
        if param_options[:shape] && value.is_a?(Hash)
          validate_shape_object(value, param_options[:shape], field_path, max_depth, current_depth)
        elsif param_options[:type] == :array && value.is_a?(Array)
          validate_array_param(value, param_options, field_path, max_depth, current_depth)
        else
          { errors: [], value: value, value_set: true }
        end
      end

      # Validate shape object
      def validate_shape_object(value, shape_def, field_path, max_depth, current_depth)
        shape_result = shape_def.validate(
          value,
          max_depth: max_depth,
          current_depth: current_depth + 1,
          path: field_path
        )
        if shape_result[:errors].any?
          { errors: shape_result[:errors], value_set: false }
        else
          { errors: [], value: shape_result[:params], value_set: true }
        end
      end

      # Validate array parameter
      def validate_array_param(value, param_options, field_path, max_depth, current_depth)
        array_validation_options = {
          param_options: param_options,
          field_path: field_path,
          max_depth: max_depth,
          current_depth: current_depth
        }
        array_errors, array_values = validate_array(value, array_validation_options)
        if array_errors.empty?
          { errors: [], value: array_values, value_set: true }
        else
          { errors: array_errors, value_set: false }
        end
      end

      # Check for unknown parameters
      def check_unknown_params(data, path)
        extra_keys = data.keys - @params.keys
        extra_keys.map do |key|
          ValidationError.field_unknown(
            field: key,
            allowed: @params.keys,
            path: path + [key]
          )
        end
      end

      # Validate array elements
      def validate_array(array, options)
        param_options = options[:param_options]
        field_path = options[:field_path]
        max_depth = options[:max_depth]
        current_depth = options[:current_depth]

        errors = []
        values = []

        # Check max items
        max_items = param_options[:max_items] || Apiwork.configuration.max_array_items
        if array.length > max_items
          errors << ValidationError.array_too_large(
            size: array.length,
            max_size: max_items,
            path: field_path
          )
          return [errors, []]
        end

        array.each_with_index do |item, index|
          item_path = field_path + [index]

          if param_options[:shape]
            # Shape object in array
            shape_result = param_options[:shape].validate(
              item,
              max_depth: max_depth,
              current_depth: current_depth + 1,
              path: item_path
            )
            if shape_result[:errors].any?
              errors.concat(shape_result[:errors])
            else
              values << shape_result[:params]
            end
          elsif param_options[:of]
            # Check if 'of' is a custom type (with scope resolution)
            custom_type_block = @contract_class.resolve_custom_type(param_options[:of], @type_scope)
            if custom_type_block
              # Array of custom type - must be a hash
              unless item.is_a?(Hash)
                errors << ValidationError.invalid_type(
                  field: index,
                  expected: param_options[:of],
                  actual: item.class.name.underscore.to_sym,
                  path: item_path
                )
                next
              end

              # Validate as shape object
              custom_def = Definition.new(@type, @contract_class, type_scope: @type_scope)
              custom_def.instance_eval(&custom_type_block)

              shape_result = custom_def.validate(
                item,
                max_depth: max_depth,
                current_depth: current_depth + 1,
                path: item_path
              )
              if shape_result[:errors].any?
                errors.concat(shape_result[:errors])
              else
                values << shape_result[:params]
              end
            else
              # Simple type array (e.g., array of strings)
              type_error = validate_type(index, item, param_options[:of], nil, item_path)
              if type_error
                errors << type_error
              else
                values << item
              end
            end
          else
            # Untyped array
            values << item
          end
        end

        [errors, values]
      end

      def validate_type(name, value, expected_type, _shape_def, path)
        case expected_type
        when :string
          return nil if value.is_a?(String)

          ValidationError.invalid_type(
            field: name,
            expected: :string,
            actual: value.class.name.underscore.to_sym,
            path: path
          )
        when :integer
          return nil if value.is_a?(Integer)

          ValidationError.invalid_type(
            field: name,
            expected: :integer,
            actual: value.class.name.underscore.to_sym,
            path: path
          )
        when :boolean
          return nil if [true, false].include?(value)

          ValidationError.invalid_type(
            field: name,
            expected: :boolean,
            actual: value.class.name.underscore.to_sym,
            path: path
          )
        when :datetime
          # Accept Time, DateTime, or ActiveSupport::TimeWithZone
          return nil if value.is_a?(Time) || value.is_a?(DateTime) || value.is_a?(ActiveSupport::TimeWithZone)

          ValidationError.invalid_type(
            field: name,
            expected: :datetime,
            actual: value.class.name.underscore.to_sym,
            path: path
          )
        when :date
          # Accept Date only
          return nil if value.is_a?(Date)

          ValidationError.invalid_type(
            field: name,
            expected: :date,
            actual: value.class.name.underscore.to_sym,
            path: path
          )
        when :uuid
          if value.is_a?(String) && value.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
            return nil
          end

          ValidationError.invalid_type(
            field: name,
            expected: :uuid,
            actual: value.class.name.underscore.to_sym,
            path: path
          )
        when :object
          return nil if value.is_a?(Hash)

          ValidationError.invalid_type(
            field: name,
            expected: :object,
            actual: value.class.name.underscore.to_sym,
            path: path
          )
        when :array
          return nil if value.is_a?(Array)

          ValidationError.invalid_type(
            field: name,
            expected: :array,
            actual: value.class.name.underscore.to_sym,
            path: path
          )
        when :decimal, :float
          return nil if value.is_a?(Numeric)

          ValidationError.invalid_type(
            field: name,
            expected: :decimal,
            actual: value.class.name.underscore.to_sym,
            path: path
          )
        else
          nil # Unknown type, don't validate
        end
      end

      # Validate union type - tries each variant in order
      # Returns [error, value] tuple
      def validate_union(name, value, union_def, path, max_depth:, current_depth:)
        variants = union_def.variants

        # Discriminated union - use discriminator field to select variant
        if union_def.discriminator
          return validate_discriminated_union(
            name, value, union_def, path, max_depth: max_depth, current_depth: current_depth
          )
        end

        # Non-discriminated union - try each variant
        variant_errors = []
        most_specific_error = nil

        variants.each do |variant_def|
          variant_type = variant_def[:type]

          # Try validating against this variant
          error, validated_value = validate_variant(
            name,
            value,
            variant_def,
            path,
            max_depth: max_depth,
            current_depth: current_depth
          )

          # Success! Return the validated value
          return [nil, validated_value] if error.nil?

          # This variant failed
          variant_errors << { type: variant_type, error: error }

          # Prioritize specific errors over generic type errors:
          # 1. field_unknown (unknown fields in nested objects)
          # 2. invalid_value (enum validation failures)
          # These are more helpful than generic "wrong type" errors
          if error.code == :field_unknown
            most_specific_error = error
          elsif error.code == :invalid_value && (!most_specific_error || most_specific_error.code != :field_unknown)
            most_specific_error = error
          end
        end

        # If we have a specific error (like field_unknown or enum validation), return it
        return [most_specific_error, nil] if most_specific_error

        # All variants failed - return error listing all expected types
        expected_types = variants.map { |v| v[:type] }
        error = ValidationError.invalid_type(
          field: name,
          expected: expected_types.join(' | '),
          actual: value.class.name.underscore.to_sym,
          path: path
        )

        [error, nil]
      end

      # Validate discriminated union - uses discriminator field to select variant
      # Returns [error, value] tuple
      def validate_discriminated_union(name, value, union_def, path, max_depth:, current_depth:)
        discriminator = union_def.discriminator
        variants = union_def.variants

        # Value must be a hash for discriminated unions
        unless value.is_a?(Hash)
          error = ValidationError.invalid_type(
            field: name,
            expected: :object,
            actual: value.class.name.underscore.to_sym,
            path: path
          )
          return [error, nil]
        end

        # Check if discriminator field exists (use key? to handle false values)
        unless value.key?(discriminator)
          error = ValidationError.new(
            code: :field_missing,
            field: discriminator,
            detail: "Discriminator field '#{discriminator}' is required",
            path: path + [discriminator]
          )
          return [error, nil]
        end

        discriminator_value = value[discriminator]

        # Find variant matching the discriminator value
        # Normalize for comparison: boolean true/false should match string 'true'/'false'
        normalized_discriminator = normalize_discriminator_value(discriminator_value)
        matching_variant = variants.find do |v|
          normalize_discriminator_value(v[:tag]) == normalized_discriminator
        end

        unless matching_variant
          valid_tags = variants.map { |v| v[:tag] }.compact
          error = ValidationError.new(
            code: :invalid_value,
            field: discriminator,
            detail: "Invalid discriminator value. Must be one of: #{valid_tags.join(', ')}",
            path: path + [discriminator],
            expected: valid_tags,
            actual: discriminator_value
          )
          return [error, nil]
        end

        # Remove discriminator field from value before validating the variant
        # The discriminator is already validated and used, variants should only see their own fields
        value_without_discriminator = value.reject { |k, _v| k == discriminator }

        # Validate against the matching variant
        error, validated_value = validate_variant(
          name,
          value_without_discriminator,
          matching_variant,
          path,
          max_depth: max_depth,
          current_depth: current_depth
        )

        # Add discriminator back to validated value
        validated_value = validated_value.merge(discriminator => discriminator_value) if validated_value.is_a?(Hash)

        [error, validated_value]
      end

      # Normalize discriminator values for comparison
      # Booleans true/false are converted to strings 'true'/'false'
      # This allows boolean discriminator values to match string tags
      def normalize_discriminator_value(value)
        case value
        when true then 'true'
        when false then 'false'
        else value
        end
      end

      # Validate a single variant of a union
      # Returns [error, value] tuple
      def validate_variant(name, value, variant_def, path, max_depth:, current_depth:)
        variant_type = variant_def[:type]
        variant_of = variant_def[:of]
        variant_shape = variant_def[:shape]

        # Handle custom types (with scope resolution)
        custom_type_block = @contract_class.resolve_custom_type(variant_type, @type_scope)
        if custom_type_block
          # Custom type variant
          custom_def = Definition.new(@type, @contract_class, type_scope: @type_scope)
          custom_def.instance_eval(&custom_type_block)

          # Must be a hash for custom type
          unless value.is_a?(Hash)
            type_error = ValidationError.invalid_type(
              field: name,
              expected: variant_type,
              actual: value.class.name.underscore.to_sym,
              path: path
            )
            return [type_error, nil]
          end

          result = custom_def.validate(
            value,
            max_depth: max_depth,
            current_depth: current_depth + 1,
            path: path
          )

          return [result[:errors].first, nil] if result[:errors].any?

          return [nil, result[:params]]
        end

        # Handle array type
        if variant_type == :array
          unless value.is_a?(Array)
            type_error = ValidationError.invalid_type(
              field: name,
              expected: :array,
              actual: value.class.name.underscore.to_sym,
              path: path
            )
            return [type_error, nil]
          end

          # Validate array items
          if variant_shape || variant_of
            array_errors, array_values = validate_array(
              value,
              {
                param_options: { shape: variant_shape, of: variant_of },
                field_path: path,
                max_depth: max_depth,
                current_depth: current_depth
              }
            )

            return [array_errors.first, nil] if array_errors.any?

            return [nil, array_values]
          end

          return [nil, value]
        end

        # Handle object type with shape definition
        if variant_type == :object && variant_shape
          unless value.is_a?(Hash)
            type_error = ValidationError.invalid_type(
              field: name,
              expected: :object,
              actual: value.class.name.underscore.to_sym,
              path: path
            )
            return [type_error, nil]
          end

          result = variant_shape.validate(
            value,
            max_depth: max_depth,
            current_depth: current_depth + 1,
            path: path
          )

          return [result[:errors].first, nil] if result[:errors].any?

          return [nil, result[:params]]
        end

        # Handle primitive types
        type_error = validate_type(name, value, variant_type, variant_shape, path)
        return [type_error, nil] if type_error

        # Validate enum if present
        if variant_def[:enum] && !variant_def[:enum].include?(value)
          enum_error = ValidationError.new(
            code: :invalid_value,
            field: name,
            detail: "Invalid value. Must be one of: #{variant_def[:enum].join(', ')}",
            path: path,
            expected: variant_def[:enum],
            actual: value
          )
          return [enum_error, nil]
        end

        [nil, value]
      end

      # Resolve enum value - if it's a symbol, resolve from Descriptors::Registry
      # If it's an array, keep as-is (inline enum)
      # @param enum [Symbol, Array, nil] Enum reference or inline values
      # @return [Hash, Array, nil] Resolved enum with metadata or inline values
      def resolve_enum_value(enum)
        return nil if enum.nil?
        return enum if enum.is_a?(Array) # Inline enum - keep as-is

        # Enum is a symbol - resolve from Descriptors::Registry with lexical scoping
        unless enum.is_a?(Symbol)
          raise ArgumentError, "enum must be a Symbol (reference) or Array (inline values), got #{enum.class}"
        end

        values = Descriptors::Registry.resolve_enum(enum, scope: self)
        if values
          # Return hash with both reference and resolved values
          # This allows serialization to use the reference and validation to use the values
          { ref: enum, values: values }
        else
          raise ArgumentError,
                "Enum :#{enum} not found. Define it using `enum :#{enum}, %w[...]` in contract or definition scope."
        end
      end
    end
  end
end
