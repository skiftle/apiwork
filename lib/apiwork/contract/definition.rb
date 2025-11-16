# frozen_string_literal: true

module Apiwork
  module Contract
    class Definition
      attr_reader :type, :params, :contract_class, :action_name, :direction

      def initialize(type:, contract_class:, action_name: nil)
        @type = type # :input or :output
        @direction = type # Alias for type (used by Descriptor::Registry.qualified_enum_name)
        @contract_class = contract_class
        @action_name = action_name
        @params = {}
      end

      def introspect
        Serialization.serialize_definition(self)
      end

      def as_json
        introspect
      end

      # Check if this definition represents an unwrapped union
      def unwrapped_union?
        @unwrapped_union
      end

      # Define a parameter
      # rubocop:disable Metrics/ParameterLists
      def param(name, type: :string, required: false, default: nil, enum: nil, of: nil, as: nil,
                discriminator: nil, value: nil, **options, &block)
        # rubocop:enable Metrics/ParameterLists
        # Validate discriminator usage
        raise ArgumentError, 'discriminator can only be used with type: :union' if discriminator && type != :union

        # Resolve enum reference if it's a symbol
        resolved_enum = resolve_enum_value(enum)

        # Dispatch to appropriate handler based on type
        case type
        when :literal
          define_literal_param(name, value: value, required: required, default: default, as: as, options: options)
        when :union
          define_union_param(name, discriminator: discriminator, resolved_enum: resolved_enum,
                                   required: required, default: default, as: as, options: options, &block)
        else
          define_regular_param(name, type: type, resolved_enum: resolved_enum,
                                     required: required, default: default, of: of, as: as, options: options, &block)
        end
      end

      private

      # Define a literal type parameter
      def define_literal_param(name, value:, required:, default:, as:, options:)
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
      end

      # Define a union type parameter
      def define_union_param(name, discriminator:, resolved_enum:, required:, default:, as:, options:, &block)
        raise ArgumentError, 'Union type requires a block with variant definitions' unless block_given?

        union_definition = UnionDefinition.new(@contract_class, discriminator: discriminator)
        union_definition.instance_eval(&block)

        @params[name] = {
          name: name,
          type: :union,
          required: required,
          default: default,
          as: as,
          union: union_definition,
          discriminator: discriminator,
          enum: resolved_enum, # Store resolved enum (values or reference)
          **options
        }
      end

      # Define a regular or custom type parameter
      def define_regular_param(name, type:, resolved_enum:, required:, default:, of:, as:, options:, &block)
        # Check if type is a custom type
        custom_type_block = @contract_class.resolve_custom_type(type)

        # Check if we're already expanding this type (prevent infinite recursion)
        if custom_type_block
          expansion_key = [@contract_class.object_id, type]
          expanding_types = Thread.current[:apiwork_expanding_custom_types] ||= Set.new

          # If already expanding this type, treat it as a reference instead of expanding
          custom_type_block = nil if expanding_types.include?(expansion_key)
        end

        if custom_type_block
          define_custom_type_param(name, type: type, custom_type_block: custom_type_block,
                                         resolved_enum: resolved_enum, required: required,
                                         default: default, of: of, as: as, options: options, &block)
        else
          define_standard_param(name, type: type, resolved_enum: resolved_enum,
                                      required: required, default: default, of: of, as: as, options: options, &block)
        end
      end

      # Define a custom type parameter with recursion protection
      # rubocop:disable Metrics/ParameterLists
      def define_custom_type_param(name, type:, custom_type_block:, resolved_enum:, required:, default:, of:, as:, options:, &block)
        # rubocop:enable Metrics/ParameterLists
        expansion_key = [@contract_class.object_id, type]
        expanding_types = Thread.current[:apiwork_expanding_custom_types] ||= Set.new
        expanding_types.add(expansion_key)

        begin
          shape_definition = Definition.new(type: @type, contract_class: @contract_class, action_name: @action_name)
          shape_definition.instance_eval(&custom_type_block)

          # Apply additional block if provided (can extend custom type)
          shape_definition.instance_eval(&block) if block_given?

          @params[name] = {
            name: name,
            type: :object, # Custom types are objects internally
            required: required,
            default: default,
            enum: resolved_enum, # Store resolved enum (values or reference)
            of: of,
            as: as,
            custom_type: type, # Track original custom type name
            shape: shape_definition,
            **options
          }
        ensure
          expanding_types.delete(expansion_key)
        end
      end

      # Define a standard (non-custom) type parameter
      def define_standard_param(name, type:, resolved_enum:, required:, default:, of:, as:, options:, &block)
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
        return unless block_given?

        shape_definition = Definition.new(type: @type, contract_class: @contract_class, action_name: @action_name)
        shape_definition.instance_eval(&block)
        @params[name][:shape] = shape_definition
      end

      public

      def validate(data, options = {})
        max_depth = options.fetch(:max_depth, 10)
        current_depth = options.fetch(:current_depth, 0)
        path = options.fetch(:path, [])

        issues = []
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
          issues.concat(param_result[:issues])
          params[name] = param_result[:value] if param_result[:value_set]
        end

        # Check for unknown params
        issues.concat(check_unknown_params(data, path))

        { issues: issues, params: params }
      end

      private

      # Return max depth error
      def max_depth_error(current_depth, max_depth, path)
        issues = [Issue.new(
          code: :max_depth_exceeded,
          message: 'Max depth exceeded',
          path: path,
          meta: { depth: current_depth, max_depth: max_depth }
        )]
        { issues: issues, params: {} }
      end

      # Validate a single parameter
      def validate_param(name, value, param_options, data, path, max_depth:, current_depth:)
        field_path = path + [name]

        # Check required
        required_error = validate_required(name, value, param_options, field_path)
        return { issues: [required_error], value_set: false } if required_error

        # Apply default if value is nil
        value = param_options[:default] if value.nil? && param_options[:default]

        # Check nullable constraint
        if data.key?(name) && value.nil? && null_value_forbidden?(param_options)
          return { issues: [Issue.new(code: :value_null, message: 'Value cannot be null', path: field_path, meta: { field: name })],
                   value_set: false }
        end

        # Skip validation if value is nil and not required
        return { issues: [], value_set: false } if value.nil?

        # Validate enum
        enum_error = validate_enum_value(name, value, param_options[:enum], field_path)
        return { issues: [enum_error], value_set: false } if enum_error

        # Handle literal type validation
        if param_options[:type] == :literal
          expected = param_options[:value]
          unless value == expected
            error = Issue.new(
              code: :invalid_value,
              message: "Value must be exactly #{expected.inspect}",
              path: field_path,
              meta: { field: name, expected: expected, actual: value }
            )
            return { issues: [error], value_set: false }
          end
          return { issues: [], value: value, value_set: true }
        end

        # Handle union type validation
        return validate_union_param(name, value, param_options, field_path, max_depth, current_depth) if param_options[:type] == :union

        # Validate type
        type_error = validate_type(name, value, param_options[:type], field_path)
        return { issues: [type_error], value_set: false } if type_error

        # Validate custom types (registered type references)
        custom_type_result = validate_custom_type(value, param_options[:type], field_path, max_depth, current_depth)
        return custom_type_result if custom_type_result

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
          # Extract values array from enum (handle both inline arrays and resolved hashes)
          enum_values = param_options[:enum].is_a?(Hash) ? param_options[:enum][:values] : param_options[:enum]

          Issue.new(
            code: :invalid_value,
            message: "Invalid value. Must be one of: #{enum_values.join(', ')}",
            path: field_path,
            meta: { field: name, expected: enum_values, actual: value }
          )
        else
          Issue.new(code: :field_missing, message: 'Field required', path: field_path, meta: { field: name })
        end
      end

      # Check if null values are explicitly forbidden (nullable: false)
      def null_value_forbidden?(param_options)
        param_options[:nullable] == false
      end

      # Validate enum value
      def validate_enum_value(name, value, enum, field_path)
        return nil if enum.nil?

        # Extract values array from enum (handle both inline arrays and resolved hashes)
        param_enum_values = enum.is_a?(Hash) ? enum[:values] : enum

        return nil if param_enum_values&.include?(value)

        Issue.new(
          code: :invalid_value,
          message: "Invalid value. Must be one of: #{param_enum_values.join(', ')}",
          path: field_path,
          meta: { field: name, expected: param_enum_values, actual: value }
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
          { issues: [union_error], value_set: false }
        else
          { issues: [], value: union_value, value_set: true }
        end
      end

      # Validate shape object or array
      def validate_shape_or_array(value, param_options, field_path, max_depth, current_depth)
        if param_options[:shape] && value.is_a?(Hash)
          validate_shape_object(value, param_options[:shape], field_path, max_depth, current_depth)
        elsif param_options[:type] == :array && value.is_a?(Array)
          validate_array_param(value, param_options, field_path, max_depth, current_depth)
        else
          { issues: [], value: value, value_set: true }
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
        if shape_result[:issues].any?
          { issues: shape_result[:issues], value_set: false }
        else
          { issues: [], value: shape_result[:params], value_set: true }
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
        array_issues, array_values = validate_array(value, array_validation_options)
        if array_issues.empty?
          { issues: [], value: array_values, value_set: true }
        else
          { issues: array_issues, value_set: false }
        end
      end

      # Check for unknown parameters
      def check_unknown_params(data, path)
        extra_keys = data.keys - @params.keys
        extra_keys.map do |key|
          Issue.new(
            code: :field_unknown,
            message: 'Unknown field',
            path: path + [key],
            meta: { field: key, allowed: @params.keys }
          )
        end
      end

      # Validate array elements
      def validate_array(array, options)
        param_options = options[:param_options]
        field_path = options[:field_path]
        max_depth = options[:max_depth]
        current_depth = options[:current_depth]

        issues = []
        values = []

        # Check max items
        max_items = param_options[:max_items] || Configuration::Resolver.resolve(
          :max_array_items,
          contract_class: @contract_class,
          schema_class: @contract_class.schema_class,
          api_class: @contract_class.api_class
        )
        if array.length > max_items
          issues << Issue.new(
            code: :array_too_large,
            message: 'Value too large',
            path: field_path,
            meta: { max_size: max_items, actual: array.length }
          )
          return [issues, []]
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
            if shape_result[:issues].any?
              issues.concat(shape_result[:issues])
            else
              values << shape_result[:params]
            end
          elsif param_options[:of]
            # Check if 'of' is a custom type (with scope resolution)
            custom_type_block = @contract_class.resolve_custom_type(param_options[:of])
            if custom_type_block
              # Array of custom type - must be a hash
              unless item.is_a?(Hash)
                issues << Issue.new(
                  code: :invalid_type,
                  message: 'Invalid type',
                  path: item_path,
                  meta: { field: index, expected: param_options[:of], actual: item.class.name.underscore.to_sym }
                )
                next
              end

              # Validate as shape object
              custom_def = Definition.new(type: @type, contract_class: @contract_class, action_name: @action_name)
              custom_def.instance_eval(&custom_type_block)

              shape_result = custom_def.validate(
                item,
                max_depth: max_depth,
                current_depth: current_depth + 1,
                path: item_path
              )
              if shape_result[:issues].any?
                issues.concat(shape_result[:issues])
              else
                values << shape_result[:params]
              end
            else
              # Simple type array (e.g., array of strings)
              type_error = validate_type(index, item, param_options[:of], item_path)
              if type_error
                issues << type_error
              else
                values << item
              end
            end
          else
            # Untyped array
            values << item
          end
        end

        [issues, values]
      end

      def validate_custom_type(value, type_name, field_path, max_depth, current_depth)
        # Return nil if not a custom type (let normal validation continue)
        return nil unless type_name.is_a?(Symbol)

        # Try to resolve custom type from registry
        type_definition = Descriptor::Registry.resolve_type(type_name, contract_class: @contract_class, scope: self)

        return nil unless type_definition # Not a registered custom type

        # Validate value against custom type definition
        type_definition.validate(value, max_depth: max_depth, current_depth: current_depth + 1, field_path: field_path)
      rescue NameError, ArgumentError => e
        # If resolution fails due to missing constant or invalid arguments, treat as non-custom type
        Rails.logger.debug("Custom type resolution failed for :#{type_name}: #{e.message}") if defined?(Rails)
        nil
      end

      def validate_type(name, value, expected_type, path)
        # Check if value matches expected type
        valid = case expected_type
                when :string then value.is_a?(String)
                when :integer then value.is_a?(Integer)
                when :boolean then [true, false].include?(value)
                when :datetime then value.is_a?(Time) || value.is_a?(DateTime) || value.is_a?(ActiveSupport::TimeWithZone)
                when :date then value.is_a?(Date)
                when :uuid then value.is_a?(String) && value.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
                when :object then value.is_a?(Hash)
                when :array then value.is_a?(Array)
                when :decimal, :float then value.is_a?(Numeric)
                else true # Unknown type, don't validate
                end

        return nil if valid

        Issue.new(
          code: :invalid_type,
          message: 'Invalid type',
          path: path,
          meta: { field: name, expected: expected_type, actual: value.class.name.underscore.to_sym }
        )
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
          elsif error.code == :invalid_value && (most_specific_error.nil? || most_specific_error.code != :field_unknown)
            most_specific_error = error
          end
        end

        # If we have a specific error (like field_unknown or enum validation), return it
        return [most_specific_error, nil] if most_specific_error

        # All variants failed - return error listing all expected types
        expected_types = variants.map { |v| v[:type] }
        error = Issue.new(
          code: :invalid_type,
          message: 'Invalid type',
          path: path,
          meta: { field: name, expected: expected_types.join(' | '), actual: value.class.name.underscore.to_sym }
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
          error = Issue.new(
            code: :invalid_type,
            message: 'Invalid type',
            path: path,
            meta: { field: name, expected: :object, actual: value.class.name.underscore.to_sym }
          )
          return [error, nil]
        end

        # Check if discriminator field exists (use key? to handle false values)
        unless value.key?(discriminator)
          error = Issue.new(
            code: :field_missing,
            message: "Discriminator field '#{discriminator}' is required",
            path: path + [discriminator],
            meta: { field: discriminator }
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
          error = Issue.new(
            code: :invalid_value,
            message: "Invalid discriminator value. Must be one of: #{valid_tags.join(', ')}",
            path: path + [discriminator],
            meta: { field: discriminator, expected: valid_tags, actual: discriminator_value }
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
        custom_type_block = @contract_class.resolve_custom_type(variant_type)
        if custom_type_block
          # Custom type variant
          custom_def = Definition.new(type: @type, contract_class: @contract_class, action_name: @action_name)
          custom_def.instance_eval(&custom_type_block)

          # Must be a hash for custom type
          unless value.is_a?(Hash)
            type_error = Issue.new(
              code: :invalid_type,
              message: 'Invalid type',
              path: path,
              meta: { field: name, expected: variant_type, actual: value.class.name.underscore.to_sym }
            )
            return [type_error, nil]
          end

          result = custom_def.validate(
            value,
            max_depth: max_depth,
            current_depth: current_depth + 1,
            path: path
          )

          return [result[:issues].first, nil] if result[:issues].any?

          return [nil, result[:params]]
        end

        # Handle array type
        if variant_type == :array
          unless value.is_a?(Array)
            type_error = Issue.new(
              code: :invalid_type,
              message: 'Invalid type',
              path: path,
              meta: { field: name, expected: :array, actual: value.class.name.underscore.to_sym }
            )
            return [type_error, nil]
          end

          # Validate array items
          if variant_shape || variant_of
            array_issues, array_values = validate_array(
              value,
              {
                param_options: { shape: variant_shape, of: variant_of },
                field_path: path,
                max_depth: max_depth,
                current_depth: current_depth
              }
            )

            return [array_issues.first, nil] if array_issues.any?

            return [nil, array_values]
          end

          return [nil, value]
        end

        # Handle object type with shape definition
        if variant_type == :object && variant_shape
          unless value.is_a?(Hash)
            type_error = Issue.new(
              code: :invalid_type,
              message: 'Invalid type',
              path: path,
              meta: { field: name, expected: :object, actual: value.class.name.underscore.to_sym }
            )
            return [type_error, nil]
          end

          result = variant_shape.validate(
            value,
            max_depth: max_depth,
            current_depth: current_depth + 1,
            path: path
          )

          return [result[:issues].first, nil] if result[:issues].any?

          return [nil, result[:params]]
        end

        # Handle primitive types
        type_error = validate_type(name, value, variant_type, path)
        return [type_error, nil] if type_error

        # Validate enum if present
        if variant_def[:enum]&.exclude?(value)
          enum_error = Issue.new(
            code: :invalid_value,
            message: "Invalid value. Must be one of: #{variant_def[:enum].join(', ')}",
            path: path,
            meta: { field: name, expected: variant_def[:enum], actual: value }
          )
          return [enum_error, nil]
        end

        [nil, value]
      end

      def resolve_enum_value(enum)
        return nil if enum.nil?
        return enum if enum.is_a?(Array) # Inline enum - keep as-is

        # Enum is a symbol - resolve from Descriptor::Registry with lexical scoping
        raise ArgumentError, "enum must be a Symbol (reference) or Array (inline values), got #{enum.class}" unless enum.is_a?(Symbol)

        values = Descriptor::Registry.resolve_enum(enum, scope: self, api_class: contract_class.api_class)

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
