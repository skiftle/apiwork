# frozen_string_literal: true

module Apiwork
  module Contract
    class Object
      class Validator
        NOT_SET = Module.new.freeze
        NUMERIC_TYPES = Set[:integer, :number, :decimal].freeze

        class << self
          def validate(shape, data, current_depth: 0, max_depth: 10, path: [])
            new(shape).validate(data, current_depth:, max_depth:, path:)
          end
        end

        ISSUE_DETAILS = {
          array_too_large: 'Too many items',
          array_too_small: 'Too few items',
          depth_exceeded: 'Too deeply nested',
          field_missing: 'Required',
          field_unknown: 'Unknown field',
          number_too_large: 'Too large',
          number_too_small: 'Too small',
          string_too_long: 'Too long',
          string_too_short: 'Too short',
          type_invalid: 'Invalid type',
          value_invalid: 'Invalid value',
          value_null: 'Cannot be null',
        }.freeze

        def initialize(shape)
          @shape = shape
        end

        def validate(data, current_depth: 0, max_depth: 10, path: [])
          issues = []
          params = {}
          data = data.deep_symbolize_keys if data.is_a?(Hash)

          return max_depth_error(current_depth, max_depth, path) if current_depth > max_depth

          @shape.params.each do |name, param_options|
            param_issues, param_value = validate_param(
              name,
              data[name],
              param_options,
              data,
              path,
              current_depth:,
              max_depth:,
            )
            issues.concat(param_issues)
            params[name] = param_value unless param_value.equal?(NOT_SET)
          end

          issues.concat(check_unknown_params(data, path))

          Result.new(issues:, params:)
        end

        private

        def max_depth_error(current_depth, max_depth, path)
          issues = [Issue.new(
            :depth_exceeded,
            translate_detail(:depth_exceeded),
            path:,
            meta: { max:, depth: current_depth },
          )]
          Result.new(issues:, params: {})
        end

        def validate_param(name, value, param_options, data, path, current_depth:, max_depth:)
          field_path = path + [name]

          required_error = validate_required(name, value, param_options, field_path)
          return [[required_error], NOT_SET] if required_error

          value = param_options[:default] if value.nil? && param_options[:default]

          nullable_error = validate_nullable(name, value, param_options, data, field_path)
          return [[nullable_error], NOT_SET] if nullable_error

          return [[], NOT_SET] if value.nil?

          enum_error = validate_enum_value(name, value, param_options[:enum], field_path)
          return [[enum_error], NOT_SET] if enum_error

          if param_options[:type] == :literal
            expected = param_options[:value]
            unless value == expected
              error = Issue.new(
                :value_invalid,
                translate_detail(:value_invalid),
                meta: {
                  expected:,
                  actual: value,
                  field: name,
                },
                path: field_path,
              )
              return [[error], NOT_SET]
            end
            return [[], value]
          end

          return validate_union_param(name, value, param_options, field_path, max_depth, current_depth) if param_options[:type] == :union

          type_error = validate_type(name, value, param_options[:type], field_path)
          return [[type_error], NOT_SET] if type_error

          if param_options[:type] == :string
            length_error = validate_string_length(name, value, param_options, field_path)
            return [[length_error], NOT_SET] if length_error
          end

          if numeric_type?(param_options[:type])
            range_error = validate_numeric_range(name, value, param_options, field_path)
            return [[range_error], NOT_SET] if range_error
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
              translate_detail(:value_invalid),
              meta: {
                actual: value,
                expected: resolve_enum(param_options[:enum]),
                field: name,
              },
              path: field_path,
            )
          else
            Issue.new(:field_missing, translate_detail(:field_missing), meta: { field: name, type: param_options[:type] }, path: field_path)
          end
        end

        def validate_nullable(name, value, param_options, data, field_path)
          return nil unless data.key?(name)
          return nil unless value.nil?
          return nil if param_options[:nullable] == true

          Issue.new(
            :value_null,
            translate_detail(:value_null),
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
            translate_detail(:value_invalid),
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
          union_error ? [[union_error], NOT_SET] : [[], union_value]
        end

        def validate_shape_or_array(value, param_options, field_path, max_depth, current_depth)
          if param_options[:shape] && value.is_a?(Hash)
            validate_shape_object(value, param_options[:shape], field_path, max_depth, current_depth)
          elsif param_options[:type] == :array && value.is_a?(Array)
            validate_array_param(value, param_options, field_path, max_depth, current_depth)
          else
            [[], value]
          end
        end

        def validate_shape_object(value, nested_shape, field_path, max_depth, current_depth)
          validator = Validator.new(nested_shape)
          shape_result = validator.validate(
            value,
            max_depth:,
            current_depth: current_depth + 1,
            path: field_path,
          )
          shape_result.invalid? ? [shape_result.issues, NOT_SET] : [[], shape_result.params]
        end

        def validate_array_param(value, param_options, field_path, max_depth, current_depth)
          array_issues, array_values = validate_array(
            value,
            {
              current_depth:,
              field_path:,
              max_depth:,
              param_options:,
            },
          )
          array_issues.empty? ? [[], array_values] : [array_issues, NOT_SET]
        end

        def check_unknown_params(data, path)
          extra_keys = data.keys - @shape.params.keys
          extra_keys.map do |key|
            Issue.new(
              :field_unknown,
              translate_detail(:field_unknown),
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
              translate_detail(:array_too_large),
              meta: { max:, actual: array.length },
              path: field_path,
            )
            return [issues, []]
          end

          if min && array.length < min
            issues << Issue.new(
              :array_too_small,
              translate_detail(:array_too_small),
              meta: { min:, actual: array.length },
              path: field_path,
            )
            return [issues, []]
          end

          array.each_with_index do |item, index|
            item_path = field_path + [index]

            if param_options[:shape]
              validator = Validator.new(param_options[:shape])
              shape_result = validator.validate(
                item,
                max_depth:,
                current_depth: current_depth + 1,
                path: item_path,
              )
              if shape_result.invalid?
                issues.concat(shape_result.issues)
              else
                values << shape_result.params
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
          of = param_options[:of]
          type_name = of.is_a?(Apiwork::Element) ? of.type : of

          type_definition = @shape.contract_class.resolve_custom_type(type_name)

          if type_definition
            return validate_array_item_with_type_definition(
              item, index, type_definition, item_path, type_name, current_depth, max_depth
            )
          end

          type_error = validate_type(index, item, type_name, item_path)
          type_error ? { issues: [type_error], value: nil } : { issues: [], value: item }
        end

        def validate_array_item_with_type_definition(item, index, type_definition, item_path, type_name, current_depth, max_depth)
          unless item.is_a?(Hash)
            return {
              issues: [Issue.new(
                :type_invalid,
                translate_detail(:type_invalid),
                meta: { index:, actual: item.class.name.underscore.to_sym, expected: type_name },
                path: item_path,
              )],
              value: nil,
            }
          end

          if type_definition.union?
            error, validated_value = validate_union(
              index, item, type_definition.shape, item_path, current_depth:, max_depth:
            )
            error ? { issues: [error], value: nil } : { issues: [], value: validated_value }
          else
            validate_array_item_with_object_type(item, type_definition, item_path, current_depth, max_depth)
          end
        end

        def validate_array_item_with_object_type(item, type_definition, item_path, current_depth, max_depth)
          result = validate_with_type_definition(type_definition, item, item_path, current_depth:, max_depth:)

          result.invalid? ? { issues: result.issues, value: nil } : { issues: [], value: result.params }
        end

        def validate_custom_type(value, type_name, field_path, max_depth, current_depth)
          return nil unless type_name.is_a?(Symbol)

          type_definition = @shape.contract_class.resolve_custom_type(type_name)
          return nil unless type_definition&.object?

          result = validate_with_type_definition(type_definition, value, field_path, current_depth:, max_depth:)
          result.invalid? ? [result.issues, NOT_SET] : [[], result.params]
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
            translate_detail(:type_invalid),
            path:,
            meta: {
              actual: value.class.name.underscore.to_sym,
              expected: expected_type,
              field: name,
            },
          )
        end

        def validate_union(name, value, union, path, current_depth:, max_depth:)
          discriminator = union.discriminator
          variants = union.variants

          if discriminator
            return [build_type_invalid_error(name, value, :object, path), nil] unless value.is_a?(Hash)

            if value.key?(discriminator)
              return validate_discriminated_variant(
                name, value, variants, discriminator, path, current_depth:, max_depth:
              )
            end

            unless discriminator_optional_in_all_variants?(discriminator, variants)
              error = Issue.new(
                :field_missing,
                translate_detail(:field_missing),
                meta: { field: discriminator },
                path: path + [discriminator],
              )
              return [error, nil]
            end
          end

          most_specific_error = nil

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
            translate_detail(:type_invalid),
            path:,
            meta: {
              actual: value.is_a?(Hash) ? :hash : value.class.name.underscore.to_sym,
              expected: expected_types.join(' | '),
              field: name,
            },
          )

          [error, nil]
        end

        def validate_discriminated_variant(name, value, variants, discriminator, path, current_depth:, max_depth:)
          discriminator_value = value[discriminator]

          normalized_discriminator = normalize_discriminator_value(discriminator_value)
          matching_variant = variants.find do |variant|
            normalize_discriminator_value(variant[:tag]) == normalized_discriminator
          end

          unless matching_variant
            valid_tags = variants.filter_map { |variant| variant[:tag] }
            error = Issue.new(
              :value_invalid,
              translate_detail(:value_invalid),
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
            return [build_type_invalid_error(name, value, variant_type, path), nil] unless value.is_a?(Hash)

            result = validate_with_type_definition(
              type_definition, value, path, current_depth:, max_depth:, exclude_param: discriminator
            )

            return [result.issues.first, nil] if result.invalid?

            return [nil, result.params]
          end

          if variant_type == :array
            return [build_type_invalid_error(name, value, :array, path), nil] unless value.is_a?(Array)

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
            return [build_type_invalid_error(name, value, :object, path), nil] unless value.is_a?(Hash)

            validator = Validator.new(variant_shape)
            result = validator.validate(
              value,
              max_depth:,
              path:,
              current_depth: current_depth + 1,
            )

            return [result.issues.first, nil] if result.invalid?

            return [nil, result.params]
          end

          type_error = validate_type(name, value, variant_type, path)
          return [type_error, nil] if type_error

          if variant[:enum]&.exclude?(value)
            enum_error = Issue.new(
              :value_invalid,
              translate_detail(:value_invalid),
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

        def discriminator_optional_in_all_variants?(discriminator, variants)
          contract_class = @shape.contract_class

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

        def validate_with_type_definition(type_definition, value, path, current_depth:, exclude_param: nil, max_depth:)
          type_shape = Object.new(@shape.contract_class, action_name: @shape.action_name)
          type_shape.copy_type_definition_params(type_definition, type_shape)
          type_shape.params.delete(exclude_param) if exclude_param

          Validator.new(type_shape).validate(value, max_depth:, path:, current_depth: current_depth + 1)
        end

        def build_type_invalid_error(name, value, expected, path)
          Issue.new(
            :type_invalid,
            translate_detail(:type_invalid),
            path:,
            meta: {
              expected:,
              actual: value.class.name.underscore.to_sym,
              field: name,
            },
          )
        end

        def validate_numeric_range(name, value, param_options, field_path)
          return nil unless value.is_a?(Numeric)

          min_value = param_options[:min]
          max_value = param_options[:max]

          if min_value && value < min_value
            return Issue.new(
              :number_too_small,
              translate_detail(:number_too_small),
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
              :number_too_large,
              translate_detail(:number_too_large),
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
              translate_detail(:string_too_short),
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
              translate_detail(:string_too_long),
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

        def translate_detail(code)
          locale_key = @shape.contract_class.api_class&.locale_key

          if locale_key
            api_key = :"apiwork.apis.#{locale_key}.issues.#{code}.detail"
            result = I18n.translate(api_key, default: nil)
            return result if result
          end

          global_key = :"apiwork.issues.#{code}.detail"
          result = I18n.translate(global_key, default: nil)
          return result if result

          ISSUE_DETAILS[code]
        end
      end
    end
  end
end
