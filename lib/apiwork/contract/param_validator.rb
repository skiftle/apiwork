# frozen_string_literal: true

module Apiwork
  module Contract
    class ParamValidator
      NUMERIC_TYPES = Set[:integer, :number, :decimal].freeze

      def initialize(shape)
        @shape = shape
      end

      def validate(data, current_depth: 0, max_depth: 10, path: [])
        issues = []
        params = {}
        data = data.deep_symbolize_keys if data.is_a?(Hash)

        return max_depth_error(current_depth, max_depth, path) if current_depth > max_depth

        @shape.params.each do |name, param_options|
          param_result = validate_param(
            name,
            data[name],
            param_options,
            data,
            path,
            current_depth:,
            max_depth:,
          )
          issues.concat(param_result[:issues])
          params[name] = param_result[:value] if param_result[:value_set]
        end

        issues.concat(check_unknown_params(data, path))

        { issues:, params: }
      end

      private

      def max_depth_error(current_depth, max_depth, path)
        issues = [Issue.new(
          :depth_exceeded,
          'Too deeply nested',
          path:,
          meta: { max:, depth: current_depth },
        )]
        { issues:, params: {} }
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
              :value_invalid,
              'Invalid value',
              meta: {
                expected:,
                actual: value,
                field: name,
              },
              path: field_path,
            )
            return { issues: [error], value_set: false }
          end
          return {
            value:,
            issues: [],
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

        missing = if param_options[:type] == :boolean
                    value.nil?
                  else
                    value.blank?
                  end

        return nil unless missing

        if param_options[:enum].present?
          Issue.new(
            :value_invalid,
            'Invalid value',
            meta: {
              actual: value,
              expected: resolve_enum(param_options[:enum]),
              field: name,
            },
            path: field_path,
          )
        else
          Issue.new(:field_missing, 'Required', meta: { field: name, type: param_options[:type] }, path: field_path)
        end
      end

      def validate_nullable(name, value, param_options, data, field_path)
        return nil unless data.key?(name)
        return nil unless value.nil?
        return nil if param_options[:nullable] == true

        Issue.new(
          :value_null,
          'Cannot be null',
          meta: { field: name, type: param_options[:type] },
          path: field_path,
        )
      end

      def validate_enum_value(name, value, enum, field_path)
        enum_values = resolve_enum(enum)
        return nil unless enum_values
        return nil if enum_values.include?(value.to_s) || enum_values.include?(value)

        Issue.new(
          :value_invalid,
          'Invalid value',
          meta: {
            actual: value,
            expected: enum_values,
            field: name,
          },
          path: field_path,
        )
      end

      def resolve_enum(enum)
        return nil if enum.nil?
        return enum if enum.is_a?(Array)

        @shape.contract_class.enum_values(enum)
      end

      def validate_union_param(name, value, param_options, field_path, max_depth, current_depth)
        union_error, union_value = validate_union(
          name,
          value,
          param_options[:union],
          field_path,
          current_depth:,
          max_depth:,
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
            value:,
            issues: [],
            value_set: true,
          }
        end
      end

      def validate_shape_object(value, shape_shape, field_path, max_depth, current_depth)
        validator = ParamValidator.new(shape_shape)
        shape_result = validator.validate(
          value,
          max_depth:,
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
          current_depth:,
          field_path:,
          max_depth:,
          param_options:,
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
        extra_keys = data.keys - @shape.params.keys
        extra_keys.map do |key|
          Issue.new(
            :field_unknown,
            'Unknown field',
            meta: { allowed: @shape.params.keys, field: key },
            path: path + [key],
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
            :array_too_large,
            'Too many items',
            meta: { max:, actual: array.length },
            path: field_path,
          )
          return [issues, []]
        end

        if min && array.length < min
          issues << Issue.new(
            :array_too_small,
            'Too few items',
            meta: { min:, actual: array.length },
            path: field_path,
          )
          return [issues, []]
        end

        array.each_with_index do |item, index|
          item_path = field_path + [index]

          if param_options[:shape]
            validator = ParamValidator.new(param_options[:shape])
            shape_result = validator.validate(
              item,
              max_depth:,
              current_depth: current_depth + 1,
              path: item_path,
            )
            if shape_result[:issues].any?
              issues.concat(shape_result[:issues])
            else
              values << shape_result[:params]
            end
          elsif param_options[:of]
            result = validate_array_item_with_type(item, index, param_options, item_path, current_depth, max_depth)
            result[:issues].any? ? issues.concat(result[:issues]) : values << result[:value]
          else
            values << item
          end
        end

        [issues, values]
      end

      def validate_array_item_with_type(item, index, param_options, item_path, current_depth, max_depth)
        contract_class_for_custom_type = @shape.contract_class
        type_definition = contract_class_for_custom_type.resolve_custom_type(param_options[:of])

        if type_definition
          return validate_array_item_with_type_definition(
            item, index, type_definition, item_path, contract_class_for_custom_type, param_options[:of], current_depth, max_depth
          )
        end

        type_error = validate_type(index, item, param_options[:of], item_path)
        type_error ? { issues: [type_error], value: nil } : { issues: [], value: item }
      end

      def validate_array_item_with_type_definition(item, index, type_definition, item_path, contract_class, type_name, current_depth, max_depth)
        unless item.is_a?(Hash)
          return {
            issues: [Issue.new(
              :type_invalid,
              'Invalid type',
              meta: { index:, actual: item.class.name.underscore.to_sym, expected: type_name },
              path: item_path,
            )],
            value: nil,
          }
        end

        if type_definition.union?
          error, validated_value = validate_union_type_definition_item(
            item, type_definition, item_path, contract_class, current_depth:, max_depth:
          )
          error ? { issues: [error], value: nil } : { issues: [], value: validated_value }
        else
          validate_array_item_with_object_type(item, type_definition, item_path, contract_class, current_depth, max_depth)
        end
      end

      def validate_array_item_with_object_type(item, type_definition, item_path, contract_class, current_depth, max_depth)
        custom_param = Object.new(contract_class, action_name: @shape.action_name)
        custom_param.copy_type_definition_params(type_definition, custom_param)

        validator = ParamValidator.new(custom_param)
        shape_result = validator.validate(item, max_depth:, current_depth: current_depth + 1, path: item_path)

        shape_result[:issues].any? ? { issues: shape_result[:issues], value: nil } : { issues: [], value: shape_result[:params] }
      end

      def validate_custom_type(value, type_name, field_path, max_depth, current_depth)
        return nil unless type_name.is_a?(Symbol)

        type_definition = @shape.contract_class&.resolve_custom_type(type_name)

        return nil unless type_definition

        type_definition.validate(value, field_path:, max_depth:, current_depth: current_depth + 1)
      rescue NameError, ArgumentError
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
                when :decimal, :number then value.is_a?(Numeric)
                else true
                end

        return nil if valid

        Issue.new(
          :type_invalid,
          'Invalid type',
          path:,
          meta: {
            actual: value.class.name.underscore.to_sym,
            expected: expected_type,
            field: name,
          },
        )
      end

      def validate_union(name, value, union, path, current_depth:, max_depth:)
        variants = union.variants

        if union.discriminator
          return validate_discriminated_union(
            name, value, union, path, current_depth:, max_depth:
          )
        end

        variant_errors = []
        most_specific_error = nil

        variants.each do |variant|
          variant_type = variant[:type]

          error, validated_value = validate_variant(
            name,
            value,
            variant,
            path,
            current_depth:,
            max_depth:,
          )

          return [nil, validated_value] if error.nil?

          variant_errors << { error:, type: variant_type }

          if error.code == :field_unknown
            most_specific_error = error
          elsif error.code == :value_invalid && (most_specific_error.nil? || most_specific_error.code != :field_unknown)
            most_specific_error = error
          end
        end

        return [most_specific_error, nil] if most_specific_error

        expected_types = variants.map { |variant| variant[:type] }
        error = Issue.new(
          :type_invalid,
          'Invalid type',
          path:,
          meta: {
            actual: value.class.name.underscore.to_sym,
            expected: expected_types.join(' | '),
            field: name,
          },
        )

        [error, nil]
      end

      def validate_discriminated_union(name, value, union, path, current_depth:, max_depth:)
        discriminator = union.discriminator
        variants = union.variants

        unless value.is_a?(Hash)
          error = Issue.new(
            :type_invalid,
            'Invalid type',
            path:,
            meta: {
              actual: value.class.name.underscore.to_sym,
              expected: :object,
              field: name,
            },
          )
          return [error, nil]
        end

        unless value.key?(discriminator)
          discriminator_optional = discriminator_optional_in_all_variants?(discriminator, variants)

          unless discriminator_optional
            error = Issue.new(
              :field_missing,
              'Required',
              meta: { field: discriminator },
              path: path + [discriminator],
            )
            return [error, nil]
          end

          return validate_union_without_discriminator(
            name, value, union, path, current_depth:, max_depth:
          )
        end

        discriminator_value = value[discriminator]

        normalized_discriminator = normalize_discriminator_value(discriminator_value)
        matching_variant = variants.find do |variant|
          normalize_discriminator_value(variant[:tag]) == normalized_discriminator
        end

        unless matching_variant
          valid_tags = variants.filter_map { |variant| variant[:tag] }
          error = Issue.new(
            :value_invalid,
            'Invalid value',
            meta: {
              actual: discriminator_value,
              expected: valid_tags,
              field: discriminator,
            },
            path: path + [discriminator],
          )
          return [error, nil]
        end

        value_without_discriminator = value.except(discriminator)

        error, validated_value = validate_variant(
          name,
          value_without_discriminator,
          matching_variant,
          path,
          current_depth:,
          discriminator:,
          max_depth:,
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

      def validate_variant(name, value, variant, path, current_depth:, discriminator: nil, max_depth:)
        variant_type = variant[:type]
        variant_of = variant[:of]
        variant_shape = variant[:shape]

        type_definition = @shape.contract_class.resolve_custom_type(variant_type)
        if type_definition
          custom_param = Object.new(
            @shape.contract_class,
            action_name: @shape.action_name,
          )
          custom_param.copy_type_definition_params(type_definition, custom_param)
          custom_param.params.delete(discriminator) if discriminator

          unless value.is_a?(Hash)
            type_error = Issue.new(
              :type_invalid,
              'Invalid type',
              path:,
              meta: {
                actual: value.class.name.underscore.to_sym,
                expected: variant_type,
                field: name,
              },
            )
            return [type_error, nil]
          end

          validator = ParamValidator.new(custom_param)
          result = validator.validate(
            value,
            max_depth:,
            path:,
            current_depth: current_depth + 1,
          )

          return [result[:issues].first, nil] if result[:issues].any?

          return [nil, result[:params]]
        end

        if variant_type == :array
          unless value.is_a?(Array)
            type_error = Issue.new(
              :type_invalid,
              'Invalid type',
              path:,
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
                current_depth:,
                max_depth:,
                field_path: path,
                param_options: { of: variant_of, shape: variant_shape },
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
              :type_invalid,
              'Invalid type',
              path:,
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
            max_depth:,
            path:,
            current_depth: current_depth + 1,
          )

          return [result[:issues].first, nil] if result[:issues].any?

          return [nil, result[:params]]
        end

        type_error = validate_type(name, value, variant_type, path)
        return [type_error, nil] if type_error

        if variant[:enum]&.exclude?(value)
          enum_error = Issue.new(
            :value_invalid,
            'Invalid value',
            path:,
            meta: {
              actual: value,
              expected: variant[:enum],
              field: name,
            },
          )
          return [enum_error, nil]
        end

        [nil, value]
      end

      def validate_union_type_definition_item(item, type_definition, item_path, contract_class, current_depth:, max_depth:)
        discriminator = type_definition.discriminator

        if discriminator && item.key?(discriminator)
          discriminator_value = item[discriminator]
          matching_variant = type_definition.variants.find do |variant|
            variant[:tag].to_s == discriminator_value.to_s
          end

          if matching_variant
            variant_type = matching_variant[:type]
            variant_type_definition = contract_class.resolve_custom_type(variant_type)

            if variant_type_definition&.object?
              custom_param = Object.new(contract_class, action_name: @shape.action_name)
              custom_param.copy_type_definition_params(variant_type_definition, custom_param)

              validator = ParamValidator.new(custom_param)
              result = validator.validate(item, max_depth:, current_depth: current_depth + 1, path: item_path)

              return [result[:issues].first, nil] if result[:issues].any?

              return [nil, result[:params]]
            end
          end
        end

        best_result = nil
        fewest_issues = Float::INFINITY

        type_definition.variants.each do |variant|
          variant_type = variant[:type]
          variant_type_definition = contract_class.resolve_custom_type(variant_type)

          next unless variant_type_definition&.object?

          custom_param = Object.new(contract_class, action_name: @shape.action_name)
          custom_param.copy_type_definition_params(variant_type_definition, custom_param)
          custom_param.params.delete(discriminator) if discriminator

          validator = ParamValidator.new(custom_param)
          result = validator.validate(item, max_depth:, current_depth: current_depth + 1, path: item_path)

          return [nil, result[:params]] if result[:issues].empty?

          if result[:issues].count < fewest_issues
            fewest_issues = result[:issues].count
            best_result = result
          end
        end

        if best_result && fewest_issues < Float::INFINITY
          [best_result[:issues].first, nil]
        else
          error = Issue.new(
            :type_invalid,
            'Invalid type',
            meta: { expected: type_definition.name },
            path: item_path,
          )
          [error, nil]
        end
      end

      def discriminator_optional_in_all_variants?(discriminator, variants)
        contract_class = @shape.contract_class
        return false unless contract_class

        variants.all? do |variant|
          variant_type = variant[:type]
          shape = variant[:shape]

          if variant_type == :object && shape
            discriminator_param = shape.params[discriminator]

          else
            type_definition = contract_class.resolve_custom_type(variant_type)
            next false unless type_definition&.object?

            discriminator_param = type_definition.shape.params[discriminator]

          end
          next false unless discriminator_param

          discriminator_param[:optional] == true
        end
      end

      def validate_union_without_discriminator(name, value, union, path, current_depth:, max_depth:)
        variants = union.variants
        discriminator = union.discriminator

        best_result = nil
        fewest_issues = Float::INFINITY

        variants.each do |variant|
          error, validated_value = validate_variant(
            name,
            value,
            variant,
            path,
            current_depth:,
            discriminator:,
            max_depth:,
          )

          return [nil, validated_value] if error.nil?

          if best_result.nil? || (error.respond_to?(:code) && error.code == :field_unknown)
            best_result = [error, nil]
            fewest_issues = 1
          end
        end

        best_result || [Issue.new(
          :type_invalid,
          'Invalid type',
          path:,
          meta: { field: name },
        ), nil]
      end

      def validate_numeric_range(name, value, param_options, field_path)
        return nil unless value.is_a?(Numeric)

        min_value = param_options[:min]
        max_value = param_options[:max]

        if min_value && value < min_value
          return Issue.new(
            :value_invalid,
            'Invalid value',
            meta: {
              actual: value,
              field: name,
              min: min_value,
            },
            path: field_path,
          )
        end

        if max_value && value > max_value
          return Issue.new(
            :value_invalid,
            'Invalid value',
            meta: {
              actual: value,
              field: name,
              max: max_value,
            },
            path: field_path,
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
            :string_too_short,
            'Too short',
            meta: {
              actual: value.length,
              field: name,
              min: min_length,
            },
            path: field_path,
          )
        end

        if max_length && value.length > max_length
          return Issue.new(
            :string_too_long,
            'Too long',
            meta: {
              actual: value.length,
              field: name,
              max: max_length,
            },
            path: field_path,
          )
        end

        nil
      end

      def numeric_type?(type)
        return false unless type

        NUMERIC_TYPES.include?(type.to_sym)
      end
    end
  end
end
