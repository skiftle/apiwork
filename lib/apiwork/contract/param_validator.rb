# frozen_string_literal: true

module Apiwork
  module Contract
    class ParamValidator
      NUMERIC_TYPES = Set[:integer, :float, :decimal].freeze

      def initialize(param_definition)
        @param_definition = param_definition
      end

      def validate(data, options = {})
        max_depth = options.fetch(:max_depth, 10)
        current_depth = options.fetch(:current_depth, 0)
        path = options.fetch(:path, [])

        issues = []
        params = {}
        data = data.deep_symbolize_keys if data.respond_to?(:deep_symbolize_keys)

        return max_depth_error(current_depth, max_depth, path) if current_depth > max_depth

        @param_definition.params.each do |name, param_options|
          param_result = validate_param(
            name,
            data[name],
            param_options,
            data,
            path,
            max_depth: max_depth,
            current_depth: current_depth,
          )
          issues.concat(param_result[:issues])
          params[name] = param_result[:value] if param_result[:value_set]
        end

        issues.concat(check_unknown_params(data, path))

        { issues: issues, params: params }
      end

      private

      def max_depth_error(current_depth, max_depth, path)
        issues = [Issue.new(
          code: :depth_exceeded,
          detail: 'Too deeply nested',
          path: path,
          meta: { depth: current_depth, max: max_depth },
        )]
        { issues: issues, params: {} }
      end

      def validate_param(name, value, param_options, data, path, current_depth:, max_depth:)
        field_path = path + [name]

        required_error = validate_required(name, value, param_options, field_path)
        return { issues: [required_error], value_set: false } if required_error

        value = param_options[:default] if value.nil? && param_options[:default]

        nullable_error = validate_nullable(name, value, param_options, data, field_path)
        return { issues: [nullable_error], value_set: false } if nullable_error

        return { issues: [], value_set: false } if value.nil?

        enum_error = validate_enum_value(name, value, param_options[:enum], field_path)
        return { issues: [enum_error], value_set: false } if enum_error

        if param_options[:type] == :literal
          expected = param_options[:value]
          unless value == expected
            error = Issue.new(
              code: :value_invalid,
              detail: 'Invalid value',
              path: field_path,
              meta: {
                actual: value,
                expected: expected,
                field: name,
              },
            )
            return { issues: [error], value_set: false }
          end
          return {
            issues: [],
            value: value,
            value_set: true,
          }
        end

        return validate_union_param(name, value, param_options, field_path, max_depth, current_depth) if param_options[:type] == :union

        type_error = validate_type(name, value, param_options[:type], field_path)
        return { issues: [type_error], value_set: false } if type_error

        if param_options[:type] == :string
          length_error = validate_string_length(name, value, param_options, field_path)
          return { issues: [length_error], value_set: false } if length_error
        end

        if numeric_type?(param_options[:type])
          range_error = validate_numeric_range(name, value, param_options, field_path)
          return { issues: [range_error], value_set: false } if range_error
        end

        custom_type_result = validate_custom_type(value, param_options[:type], field_path, max_depth, current_depth)
        return custom_type_result if custom_type_result

        validate_shape_or_array(value, param_options, field_path, max_depth, current_depth)
      end

      def validate_required(name, value, param_options, field_path)
        return nil if param_options[:optional]

        is_missing = if param_options[:type] == :boolean
                       value.nil?
                     else
                       value.blank?
                     end

        return nil unless is_missing

        if param_options[:enum].present?
          enum_values = EnumValue.values(param_options[:enum])

          Issue.new(
            code: :value_invalid,
            detail: 'Invalid value',
            path: field_path,
            meta: {
              actual: value,
              expected: enum_values,
              field: name,
            },
          )
        else
          Issue.new(code: :field_missing, detail: 'Required', meta: { field: name, type: param_options[:type] }, path: field_path)
        end
      end

      def null_value_forbidden?(param_options)
        param_options[:nullable] == false
      end

      def validate_nullable(name, value, param_options, data, field_path)
        return nil unless data.key?(name)
        return nil unless value.nil?
        return nil unless null_value_forbidden?(param_options)

        Issue.new(
          code: :value_null,
          detail: 'Cannot be null',
          path: field_path,
          meta: { field: name, type: param_options[:type] },
        )
      end

      def validate_enum_value(name, value, enum, field_path)
        return nil if EnumValue.valid?(value, enum)

        Issue.new(
          code: :value_invalid,
          detail: 'Invalid value',
          path: field_path,
          meta: {
            actual: value,
            expected: EnumValue.values(enum),
            field: name,
          },
        )
      end

      def validate_union_param(name, value, param_options, field_path, max_depth, current_depth)
        union_error, union_value = validate_union(
          name,
          value,
          param_options[:union],
          field_path,
          max_depth: max_depth,
          current_depth: current_depth,
        )
        if union_error
          { issues: [union_error], value_set: false }
        else
          {
            issues: [],
            value: union_value,
            value_set: true,
          }
        end
      end

      def validate_shape_or_array(value, param_options, field_path, max_depth, current_depth)
        if param_options[:shape] && value.is_a?(Hash)
          validate_shape_object(value, param_options[:shape], field_path, max_depth, current_depth)
        elsif param_options[:type] == :array && value.is_a?(Array)
          validate_array_param(value, param_options, field_path, max_depth, current_depth)
        else
          {
            issues: [],
            value: value,
            value_set: true,
          }
        end
      end

      def validate_shape_object(value, shape_param_definition, field_path, max_depth, current_depth)
        validator = ParamValidator.new(shape_param_definition)
        shape_result = validator.validate(
          value,
          max_depth: max_depth,
          current_depth: current_depth + 1,
          path: field_path,
        )
        if shape_result[:issues].any?
          { issues: shape_result[:issues], value_set: false }
        else
          {
            issues: [],
            value: shape_result[:params],
            value_set: true,
          }
        end
      end

      def validate_array_param(value, param_options, field_path, max_depth, current_depth)
        array_validation_options = {
          param_options: param_options,
          field_path: field_path,
          max_depth: max_depth,
          current_depth: current_depth,
        }
        array_issues, array_values = validate_array(value, array_validation_options)
        if array_issues.empty?
          {
            issues: [],
            value: array_values,
            value_set: true,
          }
        else
          { issues: array_issues, value_set: false }
        end
      end

      def check_unknown_params(data, path)
        extra_keys = data.keys - @param_definition.params.keys
        extra_keys.map do |key|
          Issue.new(
            code: :field_unknown,
            detail: 'Unknown field',
            path: path + [key],
            meta: { allowed: @param_definition.params.keys, field: key },
          )
        end
      end

      def validate_array(array, options)
        param_options = options[:param_options]
        field_path = options[:field_path]
        max_depth = options[:max_depth]
        current_depth = options[:current_depth]

        issues = []
        values = []

        max = param_options[:max]
        min = param_options[:min]

        if max && array.length > max
          issues << Issue.new(
            code: :array_too_large,
            detail: 'Too many items',
            path: field_path,
            meta: { actual: array.length, max: },
          )
          return [issues, []]
        end

        if min && array.length < min
          issues << Issue.new(
            code: :array_too_small,
            detail: 'Too few items',
            path: field_path,
            meta: { actual: array.length, min: },
          )
          return [issues, []]
        end

        array.each_with_index do |item, index|
          item_path = field_path + [index]

          if param_options[:shape]
            validator = ParamValidator.new(param_options[:shape])
            shape_result = validator.validate(
              item,
              max_depth: max_depth,
              current_depth: current_depth + 1,
              path: item_path,
            )
            if shape_result[:issues].any?
              issues.concat(shape_result[:issues])
            else
              values << shape_result[:params]
            end
          elsif param_options[:of]
            contract_class_for_custom_type = param_options[:type_contract_class] || @param_definition.contract_class
            custom_type_block = contract_class_for_custom_type.resolve_custom_type(param_options[:of])
            if custom_type_block
              unless item.is_a?(Hash)
                issues << Issue.new(
                  code: :type_invalid,
                  detail: 'Invalid type',
                  path: item_path,
                  meta: {
                    actual: item.class.name.underscore.to_sym,
                    expected: param_options[:of],
                    index: index,
                  },
                )
                next
              end

              custom_param_definition = ParamDefinition.new(
                contract_class_for_custom_type,
                action_name: @param_definition.action_name,
              )
              custom_type_block.each { |block| custom_param_definition.instance_eval(&block) }

              validator = ParamValidator.new(custom_param_definition)
              shape_result = validator.validate(
                item,
                max_depth: max_depth,
                current_depth: current_depth + 1,
                path: item_path,
              )
              if shape_result[:issues].any?
                issues.concat(shape_result[:issues])
              else
                values << shape_result[:params]
              end
            else
              type_error = validate_type(index, item, param_options[:of], item_path)
              if type_error
                issues << type_error
              else
                values << item
              end
            end
          else
            values << item
          end
        end

        [issues, values]
      end

      def validate_custom_type(value, type_name, field_path, max_depth, current_depth)
        return nil unless type_name.is_a?(Symbol)

        type_definition = @param_definition.contract_class.resolve_custom_type(type_name)

        return nil unless type_definition

        type_definition.validate(value, current_depth: current_depth + 1, field_path: field_path, max_depth: max_depth)
      rescue NameError, ArgumentError => e
        Rails.logger.debug("Custom type resolution failed for :#{type_name}: #{e.message}") if defined?(Rails)
        nil
      end

      def validate_type(name, value, expected_type, path)
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
                else true
                end

        return nil if valid

        Issue.new(
          code: :type_invalid,
          detail: 'Invalid type',
          path: path,
          meta: {
            actual: value.class.name.underscore.to_sym,
            expected: expected_type,
            field: name,
          },
        )
      end

      def validate_union(name, value, union_definition, path, current_depth:, max_depth:)
        variants = union_definition.variants

        if union_definition.discriminator
          return validate_discriminated_union(
            name, value, union_definition, path, current_depth: current_depth, max_depth: max_depth
          )
        end

        variant_errors = []
        most_specific_error = nil

        variants.each do |variant_definition|
          variant_type = variant_definition[:type]

          error, validated_value = validate_variant(
            name,
            value,
            variant_definition,
            path,
            max_depth: max_depth,
            current_depth: current_depth,
          )

          return [nil, validated_value] if error.nil?

          variant_errors << { error: error, type: variant_type }

          if error.code == :field_unknown
            most_specific_error = error
          elsif error.code == :value_invalid && (most_specific_error.nil? || most_specific_error.code != :field_unknown)
            most_specific_error = error
          end
        end

        return [most_specific_error, nil] if most_specific_error

        expected_types = variants.map { |v| v[:type] }
        error = Issue.new(
          code: :type_invalid,
          detail: 'Invalid type',
          path: path,
          meta: {
            actual: value.class.name.underscore.to_sym,
            expected: expected_types.join(' | '),
            field: name,
          },
        )

        [error, nil]
      end

      def validate_discriminated_union(name, value, union_definition, path, current_depth:, max_depth:)
        discriminator = union_definition.discriminator
        variants = union_definition.variants

        unless value.is_a?(Hash)
          error = Issue.new(
            code: :type_invalid,
            detail: 'Invalid type',
            path: path,
            meta: {
              actual: value.class.name.underscore.to_sym,
              expected: :object,
              field: name,
            },
          )
          return [error, nil]
        end

        unless value.key?(discriminator)
          error = Issue.new(
            code: :field_missing,
            detail: 'Required',
            path: path + [discriminator],
            meta: { field: discriminator },
          )
          return [error, nil]
        end

        discriminator_value = value[discriminator]

        normalized_discriminator = normalize_discriminator_value(discriminator_value)
        matching_variant = variants.find do |v|
          normalize_discriminator_value(v[:tag]) == normalized_discriminator
        end

        unless matching_variant
          valid_tags = variants.filter_map { |v| v[:tag] }
          error = Issue.new(
            code: :value_invalid,
            detail: 'Invalid value',
            path: path + [discriminator],
            meta: {
              actual: discriminator_value,
              expected: valid_tags,
              field: discriminator,
            },
          )
          return [error, nil]
        end

        value_without_discriminator = value.reject { |k, _v| k == discriminator }

        error, validated_value = validate_variant(
          name,
          value_without_discriminator,
          matching_variant,
          path,
          max_depth: max_depth,
          current_depth: current_depth,
        )

        validated_value = validated_value.merge(discriminator => discriminator_value) if validated_value.is_a?(Hash)

        [error, validated_value]
      end

      def normalize_discriminator_value(value)
        case value
        when true then 'true'
        when false then 'false'
        else value
        end
      end

      def validate_variant(name, value, variant_definition, path, current_depth:, max_depth:)
        variant_type = variant_definition[:type]
        variant_of = variant_definition[:of]
        variant_shape = variant_definition[:shape]

        custom_type_block = @param_definition.contract_class.resolve_custom_type(variant_type)
        if custom_type_block
          custom_param_definition = ParamDefinition.new(
            @param_definition.contract_class,
            action_name: @param_definition.action_name,
          )
          custom_type_block.each { |block| custom_param_definition.instance_eval(&block) }

          unless value.is_a?(Hash)
            type_error = Issue.new(
              code: :type_invalid,
              detail: 'Invalid type',
              path: path,
              meta: {
                actual: value.class.name.underscore.to_sym,
                expected: variant_type,
                field: name,
              },
            )
            return [type_error, nil]
          end

          validator = ParamValidator.new(custom_param_definition)
          result = validator.validate(
            value,
            max_depth: max_depth,
            current_depth: current_depth + 1,
            path: path,
          )

          return [result[:issues].first, nil] if result[:issues].any?

          return [nil, result[:params]]
        end

        if variant_type == :array
          unless value.is_a?(Array)
            type_error = Issue.new(
              code: :type_invalid,
              detail: 'Invalid type',
              path: path,
              meta: {
                actual: value.class.name.underscore.to_sym,
                expected: :array,
                field: name,
              },
            )
            return [type_error, nil]
          end

          if variant_shape || variant_of
            array_issues, array_values = validate_array(
              value,
              {
                param_options: { of: variant_of, shape: variant_shape },
                field_path: path,
                max_depth: max_depth,
                current_depth: current_depth,
              },
            )

            return [array_issues.first, nil] if array_issues.any?

            return [nil, array_values]
          end

          return [nil, value]
        end

        if variant_type == :object && variant_shape
          unless value.is_a?(Hash)
            type_error = Issue.new(
              code: :type_invalid,
              detail: 'Invalid type',
              path: path,
              meta: {
                actual: value.class.name.underscore.to_sym,
                expected: :object,
                field: name,
              },
            )
            return [type_error, nil]
          end

          validator = ParamValidator.new(variant_shape)
          result = validator.validate(
            value,
            max_depth: max_depth,
            current_depth: current_depth + 1,
            path: path,
          )

          return [result[:issues].first, nil] if result[:issues].any?

          return [nil, result[:params]]
        end

        type_error = validate_type(name, value, variant_type, path)
        return [type_error, nil] if type_error

        if variant_definition[:enum]&.exclude?(value)
          enum_error = Issue.new(
            code: :value_invalid,
            detail: 'Invalid value',
            path: path,
            meta: {
              actual: value,
              expected: variant_definition[:enum],
              field: name,
            },
          )
          return [enum_error, nil]
        end

        [nil, value]
      end

      def validate_numeric_range(name, value, param_options, field_path)
        return nil unless value.is_a?(Numeric)

        min_value = param_options[:min]
        max_value = param_options[:max]

        if min_value && value < min_value
          return Issue.new(
            code: :value_invalid,
            detail: 'Invalid value',
            path: field_path,
            meta: {
              actual: value,
              field: name,
              min: min_value,
            },
          )
        end

        if max_value && value > max_value
          return Issue.new(
            code: :value_invalid,
            detail: 'Invalid value',
            path: field_path,
            meta: {
              actual: value,
              field: name,
              max: max_value,
            },
          )
        end

        nil
      end

      def validate_string_length(name, value, param_options, field_path)
        return nil unless value.is_a?(String)

        return nil if value.empty?

        min_length = param_options[:min]
        max_length = param_options[:max]

        if min_length && value.length < min_length
          return Issue.new(
            code: :string_too_short,
            detail: 'Too short',
            path: field_path,
            meta: {
              actual: value.length,
              field: name,
              min: min_length,
            },
          )
        end

        if max_length && value.length > max_length
          return Issue.new(
            code: :string_too_long,
            detail: 'Too long',
            path: field_path,
            meta: {
              actual: value.length,
              field: name,
              max: max_length,
            },
          )
        end

        nil
      end

      def numeric_type?(type)
        NUMERIC_TYPES.include?(type&.to_sym)
      end
    end
  end
end
