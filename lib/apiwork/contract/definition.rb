# frozen_string_literal: true

module Apiwork
  module Contract
    class Definition
      attr_reader :action_name,
                  :contract_class,
                  :params,
                  :type

      def initialize(type:, contract_class:, action_name: nil)
        @type = type # :query, :body, or :response_body
        @contract_class = contract_class
        @action_name = action_name
        @params = {}
      end

      def resolve_option(name, subkey = nil)
        return @contract_class.schema_class.resolve_option(name, subkey) if @contract_class.schema_class

        opt = Adapter::Apiwork.options[name]
        return nil unless opt

        if opt.nested? && subkey
          opt.children[subkey]&.default
        else
          opt.resolved_default
        end
      end

      def introspect(locale: nil)
        Apiwork::Introspection.definition(self, locale:)
      end

      def as_json
        introspect
      end

      def unwrapped_union?
        @unwrapped_union
      end

      # rubocop:disable Metrics/ParameterLists
      def param(name, type: nil, optional: nil, default: nil, enum: nil, of: nil, as: nil,
                discriminator: nil, value: nil, visited_types: nil, **options, &block)
        # rubocop:enable Metrics/ParameterLists

        if @params.key?(name)
          merge_existing_param(name, type:, optional:, default:, enum:, of:, as:,
                                     discriminator:, value:, options:, &block)
          return
        end

        type ||= :string
        raise ArgumentError, 'discriminator can only be used with type: :union' if discriminator && type != :union

        visited_types = visited_types || @visited_types || Set.new

        resolved_enum = resolve_enum_value(enum)

        case type
        when :literal
          define_literal_param(name, value: value, optional: optional || false, default: default, as: as, options: options)
        when :union
          define_union_param(name, discriminator: discriminator, resolved_enum: resolved_enum,
                                   optional: optional || false, default: default, as: as, options: options, &block)
        else
          define_regular_param(name, type: type, resolved_enum: resolved_enum,
                                     optional: optional || false, default: default, of: of, as: as,
                                     visited_types: visited_types, options: options, &block)
        end
      end

      def meta(&block)
        return unless block

        existing_meta = @params[:meta]

        if existing_meta && existing_meta[:shape]
          # Meta already exists (from adapter) - extend its shape
          existing_meta[:shape].instance_eval(&block)
        else
          # First definition of meta - create it
          param :meta, type: :object, optional: true, &block
        end
      end

      private

      # rubocop:disable Metrics/ParameterLists
      def merge_existing_param(name, type:, optional:, default:, enum:, of:, as:, discriminator:, value:, options:, &block)
        # rubocop:enable Metrics/ParameterLists
        existing = @params[name]

        resolved_enum = enum ? resolve_enum_value(enum) : nil

        merged = existing.merge(options.compact)
        merged[:type] = type if type
        merged[:optional] = optional unless optional.nil?
        merged[:default] = default if default
        merged[:enum] = resolved_enum if resolved_enum
        merged[:of] = of if of
        merged[:as] = as if as
        merged[:discriminator] = discriminator if discriminator
        merged[:value] = value if value

        @params[name] = merged

        return unless block

        if existing[:union]
          existing[:union].instance_eval(&block)
        elsif existing[:shape]
          existing[:shape].instance_eval(&block)
        else
          shape_definition = Definition.new(type: nil, contract_class: @contract_class, action_name: @action_name)
          shape_definition.instance_eval(&block)
          @params[name][:shape] = shape_definition
        end
      end

      def apply_param_defaults(param_hash)
        {
          optional: false,
          nullable: nil,
          default: nil,
          as: nil,
          enum: nil,
          of: nil,
          shape: nil
        }.merge(param_hash)
      end

      def define_literal_param(name, value:, optional:, default:, as:, options:)
        raise ArgumentError, 'Literal type requires a value parameter' if value.nil? && !options.key?(:value)

        literal_value = value.nil? ? options[:value] : value

        @params[name] = apply_param_defaults({
                                               name: name,
                                               type: :literal,
                                               value: literal_value,
                                               optional: optional,
                                               default: default,
                                               as: as,
                                               **options.except(:value) # Remove :value from options to avoid duplication
                                             })
      end

      def define_union_param(name, discriminator:, resolved_enum:, optional:, default:, as:, options:, &block)
        raise ArgumentError, 'Union type requires a block with variant definitions' unless block_given?

        union_definition = UnionDefinition.new(@contract_class, discriminator: discriminator)
        union_definition.instance_eval(&block)

        @params[name] = apply_param_defaults({
                                               name: name,
                                               type: :union,
                                               optional: optional,
                                               default: default,
                                               as: as,
                                               union: union_definition,
                                               discriminator: discriminator,
                                               enum: resolved_enum, # Store resolved enum (values or reference)
                                               **options
                                             })
      end

      # rubocop:disable Metrics/ParameterLists
      def define_regular_param(name, type:, resolved_enum:, optional:, default:, of:, as:, visited_types:, options:, &block)
        # rubocop:enable Metrics/ParameterLists
        custom_type_block = @contract_class.resolve_custom_type(type)

        if custom_type_block
          expansion_key = [@contract_class.object_id, type]

          custom_type_block = nil if visited_types.include?(expansion_key)
        end

        if custom_type_block
          define_custom_type_param(name, type: type, custom_type_block: custom_type_block,
                                         resolved_enum: resolved_enum, optional: optional,
                                         default: default, of: of, as: as, visited_types: visited_types,
                                         options: options, &block)
        else
          define_standard_param(name, type: type, resolved_enum: resolved_enum,
                                      optional: optional, default: default, of: of, as: as, options: options, &block)
        end
      end

      # rubocop:disable Metrics/ParameterLists
      def define_custom_type_param(name, type:, custom_type_block:, resolved_enum:, optional:, default:, of:, as:,
                                   visited_types:, options:, &block)
        # rubocop:enable Metrics/ParameterLists
        expansion_key = [@contract_class.object_id, type]

        visited_with_current = visited_types.dup.add(expansion_key)

        shape_definition = Definition.new(type: nil, contract_class: @contract_class, action_name: @action_name)

        shape_definition.instance_variable_set(:@visited_types, visited_with_current)

        custom_type_block.each do |definition_block|
          shape_definition.instance_eval(&definition_block)
        end

        shape_definition.instance_eval(&block) if block_given?

        @params[name] = apply_param_defaults({
                                               name: name,
                                               type: :object, # Custom types are objects internally
                                               optional: optional,
                                               default: default,
                                               enum: resolved_enum, # Store resolved enum (values or reference)
                                               of: of,
                                               as: as,
                                               custom_type: type, # Track original custom type name
                                               shape: shape_definition,
                                               **options
                                             })
      end

      def define_standard_param(name, type:, resolved_enum:, optional:, default:, of:, as:, options:, &block)
        @params[name] = apply_param_defaults({
                                               name: name,
                                               type: type,
                                               optional: optional,
                                               default: default,
                                               enum: resolved_enum, # Store resolved enum (values or reference)
                                               of: of,
                                               as: as,
                                               **options
                                             })

        return unless block_given?

        shape_definition = Definition.new(type: nil, contract_class: @contract_class, action_name: @action_name)
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

        return max_depth_error(current_depth, max_depth, path) if current_depth > max_depth

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

        issues.concat(check_unknown_params(data, path))

        { issues: issues, params: params }
      end

      private

      def max_depth_error(current_depth, max_depth, path)
        issues = [Issue.new(
          code: :max_depth_exceeded,
          detail: 'Max depth exceeded',
          path: path,
          meta: { depth: current_depth, max_depth: max_depth }
        )]
        { issues: issues, params: {} }
      end

      def validate_param(name, value, param_options, data, path, max_depth:, current_depth:)
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
              code: :invalid_value,
              detail: "Value must be exactly #{expected.inspect}",
              path: field_path,
              meta: { field: name, expected: expected, actual: value }
            )
            return { issues: [error], value_set: false }
          end
          return { issues: [], value: value, value_set: true }
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
            code: :invalid_value,
            detail: "Invalid value. Must be one of: #{EnumValue.format(param_options[:enum])}",
            path: field_path,
            meta: { field: name, expected: enum_values, actual: value }
          )
        else
          Issue.new(code: :field_missing, detail: 'Field required', path: field_path, meta: { field: name })
        end
      end

      def null_value_forbidden?(param_options)
        param_options[:nullable] == false # Explicit false check needed to distinguish from nil
      end

      def validate_nullable(name, value, param_options, data, field_path)
        return nil unless data.key?(name)
        return nil unless value.nil?
        return nil unless null_value_forbidden?(param_options)

        Issue.new(
          code: :value_null,
          detail: 'Value cannot be null',
          path: field_path,
          meta: { field: name }
        )
      end

      def validate_enum_value(name, value, enum, field_path)
        return nil if EnumValue.valid?(value, enum)

        Issue.new(
          code: :invalid_value,
          detail: "Invalid value. Must be one of: #{EnumValue.format(enum)}",
          path: field_path,
          meta: { field: name, expected: EnumValue.values(enum), actual: value }
        )
      end

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

      def validate_shape_or_array(value, param_options, field_path, max_depth, current_depth)
        if param_options[:shape] && value.is_a?(Hash)
          validate_shape_object(value, param_options[:shape], field_path, max_depth, current_depth)
        elsif param_options[:type] == :array && value.is_a?(Array)
          validate_array_param(value, param_options, field_path, max_depth, current_depth)
        else
          { issues: [], value: value, value_set: true }
        end
      end

      def validate_shape_object(value, shape_definition, field_path, max_depth, current_depth)
        shape_result = shape_definition.validate(
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

      def check_unknown_params(data, path)
        extra_keys = data.keys - @params.keys
        extra_keys.map do |key|
          Issue.new(
            code: :field_unknown,
            detail: 'Unknown field',
            path: path + [key],
            meta: { field: key, allowed: @params.keys }
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
            detail: 'Array exceeds maximum length',
            path: field_path,
            meta: { max:, actual: array.length }
          )
          return [issues, []]
        end

        if min && array.length < min
          issues << Issue.new(
            code: :array_too_small,
            detail: 'Array below minimum length',
            path: field_path,
            meta: { min:, actual: array.length }
          )
          return [issues, []]
        end

        array.each_with_index do |item, index|
          item_path = field_path + [index]

          if param_options[:shape]
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
            contract_class_for_custom_type = param_options[:type_contract_class] || @contract_class
            custom_type_block = contract_class_for_custom_type.resolve_custom_type(param_options[:of])
            if custom_type_block
              unless item.is_a?(Hash)
                issues << Issue.new(
                  code: :invalid_type,
                  detail: 'Invalid type',
                  path: item_path,
                  meta: { field: index, expected: param_options[:of], actual: item.class.name.underscore.to_sym }
                )
                next
              end

              custom_definition = Definition.new(type: @type, contract_class: contract_class_for_custom_type, action_name: @action_name)
              custom_type_block.each { |block| custom_definition.instance_eval(&block) }

              shape_result = custom_definition.validate(
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

        type_definition = @contract_class.resolve_custom_type(type_name)

        return nil unless type_definition # Not a registered custom type

        type_definition.validate(value, max_depth: max_depth, current_depth: current_depth + 1, field_path: field_path)
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
                else true # Unknown type, don't validate
                end

        return nil if valid

        Issue.new(
          code: :invalid_type,
          detail: 'Invalid type',
          path: path,
          meta: { field: name, expected: expected_type, actual: value.class.name.underscore.to_sym }
        )
      end

      def validate_union(name, value, union_def, path, max_depth:, current_depth:)
        variants = union_def.variants

        if union_def.discriminator
          return validate_discriminated_union(
            name, value, union_def, path, max_depth: max_depth, current_depth: current_depth
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
            current_depth: current_depth
          )

          return [nil, validated_value] if error.nil?

          variant_errors << { type: variant_type, error: error }

          if error.code == :field_unknown
            most_specific_error = error
          elsif error.code == :invalid_value && (most_specific_error.nil? || most_specific_error.code != :field_unknown)
            most_specific_error = error
          end
        end

        return [most_specific_error, nil] if most_specific_error

        expected_types = variants.map { |v| v[:type] }
        error = Issue.new(
          code: :invalid_type,
          detail: 'Invalid type',
          path: path,
          meta: { field: name, expected: expected_types.join(' | '), actual: value.class.name.underscore.to_sym }
        )

        [error, nil]
      end

      def validate_discriminated_union(name, value, union_def, path, max_depth:, current_depth:)
        discriminator = union_def.discriminator
        variants = union_def.variants

        unless value.is_a?(Hash)
          error = Issue.new(
            code: :invalid_type,
            detail: 'Invalid type',
            path: path,
            meta: { field: name, expected: :object, actual: value.class.name.underscore.to_sym }
          )
          return [error, nil]
        end

        unless value.key?(discriminator)
          error = Issue.new(
            code: :field_missing,
            detail: "Discriminator field '#{discriminator}' is required",
            path: path + [discriminator],
            meta: { field: discriminator }
          )
          return [error, nil]
        end

        discriminator_value = value[discriminator]

        normalized_discriminator = normalize_discriminator_value(discriminator_value)
        matching_variant = variants.find do |v|
          normalize_discriminator_value(v[:tag]) == normalized_discriminator
        end

        unless matching_variant
          valid_tags = variants.map { |v| v[:tag] }.compact
          error = Issue.new(
            code: :invalid_value,
            detail: "Invalid discriminator value. Must be one of: #{valid_tags.join(', ')}",
            path: path + [discriminator],
            meta: { field: discriminator, expected: valid_tags, actual: discriminator_value }
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
          current_depth: current_depth
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

      def validate_variant(name, value, variant_definition, path, max_depth:, current_depth:)
        variant_type = variant_definition[:type]
        variant_of = variant_definition[:of]
        variant_shape = variant_definition[:shape]

        custom_type_block = @contract_class.resolve_custom_type(variant_type)
        if custom_type_block
          custom_definition = Definition.new(type: @type, contract_class: @contract_class, action_name: @action_name)
          custom_type_block.each { |block| custom_definition.instance_eval(&block) }

          unless value.is_a?(Hash)
            type_error = Issue.new(
              code: :invalid_type,
              detail: 'Invalid type',
              path: path,
              meta: { field: name, expected: variant_type, actual: value.class.name.underscore.to_sym }
            )
            return [type_error, nil]
          end

          result = custom_definition.validate(
            value,
            max_depth: max_depth,
            current_depth: current_depth + 1,
            path: path
          )

          return [result[:issues].first, nil] if result[:issues].any?

          return [nil, result[:params]]
        end

        if variant_type == :array
          unless value.is_a?(Array)
            type_error = Issue.new(
              code: :invalid_type,
              detail: 'Invalid type',
              path: path,
              meta: { field: name, expected: :array, actual: value.class.name.underscore.to_sym }
            )
            return [type_error, nil]
          end

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

        if variant_type == :object && variant_shape
          unless value.is_a?(Hash)
            type_error = Issue.new(
              code: :invalid_type,
              detail: 'Invalid type',
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

        type_error = validate_type(name, value, variant_type, path)
        return [type_error, nil] if type_error

        if variant_definition[:enum]&.exclude?(value)
          enum_error = Issue.new(
            code: :invalid_value,
            detail: "Invalid value. Must be one of: #{variant_definition[:enum].join(', ')}",
            path: path,
            meta: { field: name, expected: variant_definition[:enum], actual: value }
          )
          return [enum_error, nil]
        end

        [nil, value]
      end

      def resolve_enum_value(enum)
        return nil if enum.nil?
        return enum if enum.is_a?(Array) # Inline enum - keep as-is

        raise ArgumentError, "enum must be a Symbol (reference) or Array (inline values), got #{enum.class}" unless enum.is_a?(Symbol)

        values = @contract_class.resolve_enum(enum)

        if values
          { ref: enum, values: values }
        else
          raise ArgumentError,
                "Enum :#{enum} not found. Define it using `enum :#{enum}, %w[...]` in contract or definition scope."
        end
      end

      def validate_numeric_range(name, value, param_options, field_path)
        return nil unless value.is_a?(Numeric)

        min_value = param_options[:min]
        max_value = param_options[:max]

        if min_value && value < min_value
          return Issue.new(
            code: :invalid_value,
            detail: "Value must be >= #{min_value}",
            path: field_path,
            meta: { field: name, actual: value, minimum: min_value }
          )
        end

        if max_value && value > max_value
          return Issue.new(
            code: :invalid_value,
            detail: "Value must be <= #{max_value}",
            path: field_path,
            meta: { field: name, actual: value, maximum: max_value }
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
            detail: "String must be at least #{min_length} characters",
            path: field_path,
            meta: { field: name, actual_length: value.length, min_length: }
          )
        end

        if max_length && value.length > max_length
          return Issue.new(
            code: :string_too_long,
            detail: "String must be at most #{max_length} characters",
            path: field_path,
            meta: { field: name, actual_length: value.length, max_length: }
          )
        end

        nil
      end

      def numeric_type?(type)
        [:integer, :float, :decimal, :number].include?(type&.to_sym)
      end
    end
  end
end
