# frozen_string_literal: true

require_relative 'union_definition'

module Apiwork
  module Contract
    class Definition
      attr_reader :type, :params, :contract_class

      def initialize(type, contract_class)
        @type = type # :input or :output
        @contract_class = contract_class
        @params = {}
      end

      # Define a parameter
      def param(name, type: :string, required: false, default: nil, enum: nil, of: nil, **options, &block) # rubocop:disable Metrics/ParameterLists
        # Handle union types
        if type == :union
          raise ArgumentError, "Union type requires a block with variant definitions" unless block_given?

          union_def = UnionDefinition.new(@contract_class)
          union_def.instance_eval(&block)

          @params[name] = {
            name: name,
            type: :union,
            required: required,
            default: default,
            union: union_def,
            **options
          }
          return
        end

        # Check if type is a custom type
        if @contract_class.custom_types&.key?(type)
          # Custom type - resolve it
          custom_type_block = @contract_class.custom_types[type]
          nested_def = Definition.new(@type, @contract_class)
          nested_def.instance_eval(&custom_type_block)

          # Apply additional block if provided (can extend custom type)
          nested_def.instance_eval(&block) if block_given?

          @params[name] = {
            name: name,
            type: :object, # Custom types are objects internally
            required: required,
            default: default,
            enum: enum,
            of: of,
            custom_type: type, # Track original custom type name
            nested: nested_def,
            **options
          }
        else
          # Regular type
          @params[name] = {
            name: name,
            type: type,
            required: required,
            default: default,
            enum: enum,
            of: of,
            **options
          }

          # Handle nested param with do block
          if block_given?
            nested_def = Definition.new(@type, @contract_class)
            nested_def.instance_eval(&block)
            @params[name][:nested] = nested_def
          end
        end
      end

      # Validate data against this definition
      # @param data [Hash] Data to validate
      # @param options [Hash] Validation options
      # @option options [Integer] :max_depth Maximum nesting depth (default: 10)
      # @option options [Integer] :current_depth Current depth (for recursion)
      # @option options [Array] :path Current path (for error messages)
      # @option options [Boolean] :coerce Whether to coerce types (default: true)
      def validate(data, options = {})
        max_depth = options.fetch(:max_depth, 10)
        current_depth = options.fetch(:current_depth, 0)
        path = options.fetch(:path, [])
        coerce = options.fetch(:coerce, true)

        errors = []
        params = {}
        data = data.deep_symbolize_keys if data.respond_to?(:deep_symbolize_keys)

        # Check max depth
        if current_depth > max_depth
          errors << ValidationError.max_depth_exceeded(
            depth: current_depth,
            max_depth: max_depth,
            path: path
          )
          return { errors: errors, params: {} }
        end

        @params.each do |name, param_options|
          value = data[name]
          field_path = path + [name]

          # Check required (matches Rails params.require behavior)
          # Rejects: nil, empty string, empty hash, empty array
          is_missing = value.blank?

          if param_options[:required] && is_missing
            # For enum fields, return invalid_value error to show allowed values immediately
            if param_options[:enum].present?
              errors << ValidationError.new(
                code: :invalid_value,
                field: name,
                detail: "Invalid value. Must be one of: #{param_options[:enum].join(', ')}",
                path: field_path,
                expected: param_options[:enum],
                actual: value
              )
              next
            else
              # Non-enum fields get field_missing error
              errors << ValidationError.field_missing(
                field: name,
                path: field_path
              )
              next
            end
          end

          # Apply default if value is nil
          value = param_options[:default] if value.nil? && param_options[:default]

          # Check nullable constraint
          # Only check if the field is actually present in the data
          # If value is nil and nullable is explicitly false, add error
          if data.key?(name) && value.nil? && param_options[:nullable] == false
            errors << ValidationError.value_null(field: name, path: field_path)
            next
          end

          # Skip validation if value is nil and not required
          next if value.nil?

          # Coerce type if enabled
          if coerce && Coercer.can_coerce?(param_options[:type])
            coerced_value = Coercer.coerce(value, param_options[:type])
            value = coerced_value unless coerced_value.nil?
          end

          # Validate enum
          if param_options[:enum]&.exclude?(value)
            errors << ValidationError.new(
              code: :invalid_value,
              field: name,
              detail: "Invalid value. Must be one of: #{param_options[:enum].join(', ')}",
              path: field_path,
              expected: param_options[:enum],
              actual: value
            )
            next
          end

          # Handle union type validation
          if param_options[:type] == :union
            union_error, union_value = validate_union(
              name,
              value,
              param_options[:union],
              field_path,
              max_depth: max_depth,
              current_depth: current_depth,
              coerce: coerce
            )
            if union_error
              errors << union_error
              next
            end
            params[name] = union_value
            next
          end

          # Validate type
          type_error = validate_type(name, value, param_options[:type], param_options[:nested], field_path)
          if type_error
            errors << type_error
            next
          end

          # Validate nested object
          if param_options[:nested] && value.is_a?(Hash)
            nested_result = param_options[:nested].validate(
              value,
              max_depth: max_depth,
              current_depth: current_depth + 1,
              path: field_path,
              coerce: coerce
            )
            if nested_result[:errors].any?
              errors.concat(nested_result[:errors])
              next
            end
            params[name] = nested_result[:params]
          elsif param_options[:type] == :array && value.is_a?(Array)
            # Validate array elements
            array_validation_options = {
              param_options: param_options,
              field_path: field_path,
              max_depth: max_depth,
              current_depth: current_depth,
              coerce: coerce
            }
            array_errors, array_values = validate_array(value, array_validation_options)
            errors.concat(array_errors)
            params[name] = array_values if array_errors.empty?
          else
            params[name] = value
          end
        end

        # Check for unknown params
        extra_keys = data.keys - @params.keys
        extra_keys.each do |key|
          errors << ValidationError.field_unknown(
            field: key,
            allowed: @params.keys,
            path: path + [key]
          )
        end

        {
          errors: errors,
          params: params
        }
      end

      private

      # Validate array elements
      def validate_array(array, options)
        param_options = options[:param_options]
        field_path = options[:field_path]
        max_depth = options[:max_depth]
        current_depth = options[:current_depth]
        coerce = options[:coerce]

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

          if param_options[:nested]
            # Nested object in array
            nested_result = param_options[:nested].validate(
              item,
              max_depth: max_depth,
              current_depth: current_depth + 1,
              path: item_path,
              coerce: coerce
            )
            if nested_result[:errors].any?
              errors.concat(nested_result[:errors])
            else
              values << nested_result[:params]
            end
          elsif param_options[:of]
            # Check if 'of' is a custom type
            if @contract_class.custom_types&.key?(param_options[:of])
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

              # Validate as nested object
              custom_type_block = @contract_class.custom_types[param_options[:of]]
              custom_def = Definition.new(@type, @contract_class)
              custom_def.instance_eval(&custom_type_block)

              nested_result = custom_def.validate(
                item,
                max_depth: max_depth,
                current_depth: current_depth + 1,
                path: item_path,
                coerce: coerce
              )
              if nested_result[:errors].any?
                errors.concat(nested_result[:errors])
              else
                values << nested_result[:params]
              end
            else
              # Simple type array (e.g., array of strings)
              # Coerce the item if coercion is enabled
              coerced_item = coerce ? Coercer.coerce(item, param_options[:of]) : item

              type_error = validate_type(index, coerced_item, param_options[:of], nil, item_path)
              if type_error
                errors << type_error
              else
                values << coerced_item
              end
            end
          else
            # Untyped array
            values << item
          end
        end

        [errors, values]
      end

      def validate_type(name, value, expected_type, _nested_def, path)
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
          # If string found, coercion must have failed
          if value.is_a?(String)
            return ValidationError.coercion_failed(
              field: name,
              type: :datetime,
              value: value,
              path: path
            )
          end

          # Accept Time, DateTime, or ActiveSupport::TimeWithZone
          return nil if value.is_a?(Time) || value.is_a?(DateTime) || value.is_a?(ActiveSupport::TimeWithZone)

          ValidationError.invalid_type(
            field: name,
            expected: :datetime,
            actual: value.class.name.underscore.to_sym,
            path: path
          )
        when :date
          # If string found, coercion must have failed
          if value.is_a?(String)
            return ValidationError.coercion_failed(
              field: name,
              type: :date,
              value: value,
              path: path
            )
          end

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
      def validate_union(name, value, union_def, path, max_depth:, current_depth:, coerce:)
        variants = union_def.variants
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
            current_depth: current_depth,
            coerce: coerce
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

      # Validate a single variant of a union
      # Returns [error, value] tuple
      def validate_variant(name, value, variant_def, path, max_depth:, current_depth:, coerce:)
        variant_type = variant_def[:type]
        variant_of = variant_def[:of]
        variant_nested = variant_def[:nested]

        # Handle custom types
        if @contract_class.custom_types&.key?(variant_type)
          # Custom type variant
          custom_type_block = @contract_class.custom_types[variant_type]
          custom_def = Definition.new(@type, @contract_class)
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
            path: path,
            coerce: coerce
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
          if variant_nested || variant_of
            array_errors, array_values = validate_array(
              value,
              {
                param_options: { nested: variant_nested, of: variant_of },
                field_path: path,
                max_depth: max_depth,
                current_depth: current_depth,
                coerce: coerce
              }
            )

            return [array_errors.first, nil] if array_errors.any?

            return [nil, array_values]
          end

          return [nil, value]
        end

        # Handle object type with nested definition
        if variant_type == :object && variant_nested
          unless value.is_a?(Hash)
            type_error = ValidationError.invalid_type(
              field: name,
              expected: :object,
              actual: value.class.name.underscore.to_sym,
              path: path
            )
            return [type_error, nil]
          end

          result = variant_nested.validate(
            value,
            max_depth: max_depth,
            current_depth: current_depth + 1,
            path: path,
            coerce: coerce
          )

          return [result[:errors].first, nil] if result[:errors].any?

          return [nil, result[:params]]
        end

        # Handle primitive types
        # Coerce value if coercion is enabled - but only for boolean to handle query params
        coerced_value = value
        if coerce && variant_type == :boolean && Coercer.can_coerce?(:boolean)
          coerced = Coercer.coerce(value, :boolean)
          coerced_value = coerced unless coerced.nil?
        end

        type_error = validate_type(name, coerced_value, variant_type, variant_nested, path)
        return [type_error, nil] if type_error

        # Validate enum if present
        if variant_def[:enum] && !variant_def[:enum].include?(coerced_value)
          enum_error = ValidationError.new(
            code: :invalid_value,
            field: name,
            detail: "Invalid value. Must be one of: #{variant_def[:enum].join(', ')}",
            path: path,
            expected: variant_def[:enum],
            actual: coerced_value
          )
          return [enum_error, nil]
        end

        [nil, coerced_value]
      end
    end
  end
end
