# frozen_string_literal: true

module Apiwork
  module Introspection
    module Dump
      class Param
        def initialize(contract_param, result_wrapper: nil, visited: Set.new)
          @contract_param = contract_param
          @result_wrapper = result_wrapper
          @visited = visited
          @import_prefix_cache = {}
        end

        def to_h
          return nil unless @contract_param

          return build_result_wrapped if @result_wrapper

          result = {}

          @contract_param.params.sort_by { |name, _options| name.to_s }.each do |name, param_options|
            result[name] = build_param(name, param_options)
          end

          if @contract_param.wrapped?
            { shape: result, type: :object }
          else
            result
          end
        end

        private

        def build_result_wrapped
          success_type = @result_wrapper[:success_type]
          error_type = @result_wrapper[:error_type]

          success_variant = if success_type
                              { ref: success_type, type: :ref }
                            else
                              { ref: nil, shape: build_success_params, type: :object }
                            end

          error_variant = if error_type
                            { ref: error_type, type: :ref }
                          else
                            { ref: nil, shape: {}, type: :object }
                          end

          {
            type: :union,
            variants: [success_variant, error_variant],
          }
        end

        def build_success_params
          success_params = {}
          @contract_param.params.sort_by { |name, _options| name.to_s }.each do |name, param_options|
            dumped = build_param(name, param_options)
            dumped[:optional] = true if param_options[:optional]
            success_params[name] = dumped
          end
          success_params
        end

        def build_param(name, options)
          return build_union_param(options) if options[:type] == :union
          return build_custom_type_param(options) if options[:custom_type]

          ref = resolve_type_ref(options[:type])

          {
            ref:,
            as: options[:as],
            default: options[:default],
            deprecated: options[:deprecated] == true,
            description: resolve_attribute_description(options),
            discriminator: nil,
            enum: resolve_enum(options),
            example: options[:example],
            format: options[:format],
            max: options[:max],
            min: options[:min],
            nullable: options[:nullable] == true,
            of: resolve_of(options),
            optional: options[:optional] == true,
            partial: options[:partial] == true,
            shape: build_shape(options) || {},
            tag: nil,
            type: ref ? :ref : (options[:type] || :unknown),
            value: options[:type] == :literal ? options[:value] : nil,
            variants: [],
          }
        end

        def build_union_param(options)
          union_data = build_union(options[:union])

          {
            as: options[:as],
            default: options[:default],
            deprecated: options[:deprecated] == true,
            description: resolve_attribute_description(options),
            discriminator: union_data[:discriminator],
            enum: nil,
            example: options[:example],
            format: options[:format],
            max: nil,
            min: nil,
            nullable: options[:nullable] == true,
            of: nil,
            optional: options[:optional] == true,
            partial: false,
            ref: nil,
            shape: {},
            tag: nil,
            type: :union,
            value: nil,
            variants: union_data[:variants],
          }
        end

        def build_custom_type_param(options)
          custom_type_name = options[:custom_type]
          custom_type_name = qualified_name(custom_type_name, @contract_param) if @contract_param.contract_class.resolve_custom_type(custom_type_name)

          {
            as: options[:as],
            default: options[:default],
            deprecated: options[:deprecated] == true,
            description: resolve_attribute_description(options),
            discriminator: nil,
            enum: nil,
            example: options[:example],
            format: options[:format],
            max: nil,
            min: nil,
            nullable: options[:nullable] == true,
            of: nil,
            optional: options[:optional] == true,
            partial: false,
            ref: custom_type_name,
            shape: {},
            tag: nil,
            type: :ref,
            value: nil,
            variants: [],
          }
        end

        def resolve_type_ref(type_value)
          return nil unless type_value
          return nil unless registered_type?(type_value)

          qualified_name(type_value, @contract_param)
        end

        def registered_type?(type_value)
          return false unless type_value.is_a?(Symbol)

          contract_class = @contract_param.contract_class
          return true if contract_class.resolve_custom_type(type_value)
          return true if contract_class.enum?(type_value)

          api_class = contract_class.api_class
          return false unless api_class

          scoped_name = api_class.scoped_name(contract_class, type_value)
          return true if api_class.type_system.types.key?(scoped_name) || api_class.type_system.types.key?(type_value)
          return true if api_class.type_system.enums.key?(scoped_name) || api_class.type_system.enums.key?(type_value)

          false
        end

        def resolve_enum(options)
          return nil unless options[:enum]

          if options[:enum].is_a?(Symbol)
            scope = scope_for_enum(@contract_param, options[:enum])
            api_class = @contract_param.contract_class.api_class
            api_class.scoped_name(scope, options[:enum])
          else
            options[:enum]
          end
        end

        def resolve_of(options)
          return nil unless options[:of]

          if registered_type?(options[:of])
            ref_name = qualified_name(options[:of], @contract_param)
            { ref: ref_name, shape: {}, type: :ref }
          else
            build_of_hash(options[:of])
          end
        end

        def build_of_hash(type_symbol)
          result = { ref: nil, type: type_symbol }
          result[:shape] = {} if [:object, :array].include?(type_symbol)
          result
        end

        def build_union(union_definition)
          {
            discriminator: union_definition.discriminator,
            variants: union_definition.variants.map { |variant| build_variant(variant) },
          }
        end

        def build_variant(variant_definition)
          variant_type = variant_definition[:type]
          is_registered = registered_type?(variant_type)

          ref = is_registered ? qualified_name(variant_type, @contract_param) : nil
          resolved_type = is_registered ? :ref : (variant_type || :unknown)

          {
            ref:,
            as: nil,
            default: nil,
            deprecated: false,
            description: nil,
            discriminator: nil,
            enum: resolve_variant_enum(variant_definition),
            example: nil,
            format: nil,
            max: nil,
            min: nil,
            nullable: false,
            of: resolve_variant_of(variant_definition),
            optional: false,
            partial: false,
            shape: resolve_variant_shape(variant_definition, variant_type),
            tag: variant_definition[:tag],
            type: resolved_type,
            value: nil,
            variants: [],
          }
        end

        def resolve_variant_enum(variant_definition)
          return nil unless variant_definition[:enum]

          if variant_definition[:enum].is_a?(Symbol)
            if @contract_param.contract_class.respond_to?(:schema_class) &&
               @contract_param.contract_class.schema_class
              scope = scope_for_enum(@contract_param, variant_definition[:enum])
              api_class = @contract_param.contract_class.api_class
              api_class.scoped_name(scope, variant_definition[:enum])
            else
              variant_definition[:enum]
            end
          else
            variant_definition[:enum]
          end
        end

        def resolve_variant_of(variant_definition)
          return nil unless variant_definition[:of]

          if registered_type?(variant_definition[:of])
            ref_name = qualified_name(variant_definition[:of], @contract_param)
            { ref: ref_name, shape: {}, type: :ref }
          else
            build_of_hash(variant_definition[:of])
          end
        end

        def resolve_variant_shape(variant_definition, variant_type)
          if variant_definition[:shape]
            build_nested_shape(variant_definition[:shape])
          else
            {}
          end
        end

        def build_nested_shape(shape_definition)
          Param.new(shape_definition, visited: @visited).to_h
        end

        def build_shape(options)
          dumped = options[:shape] ? build_nested_shape(options[:shape]) : nil

          return dumped || {} if [:object, :array].include?(options[:type])

          dumped
        end

        def resolve_attribute_description(options)
          return options[:description] if options[:description]

          param_name = options[:name]
          return nil unless param_name

          schema_class = resolve_schema_class
          return nil unless schema_class

          if (attribute_definition = schema_class.attribute_definitions[param_name])
            description = i18n_attribute_description(attribute_definition)
            return description if description
          end

          if (association_definition = schema_class.association_definitions[param_name])
            description = i18n_association_description(association_definition)
            return description if description
          end

          nil
        end

        def resolve_schema_class
          contract_class = @contract_param.contract_class
          return contract_class.schema_class if contract_class.respond_to?(:schema_class) && contract_class.schema_class

          nil
        end

        def i18n_attribute_description(attribute_definition)
          api_class = @contract_param.contract_class.api_class
          return nil unless api_class

          schema_name = attribute_definition.schema_class_name
          attribute_name = attribute_definition.name

          api_class.structure.i18n_lookup(:schemas, schema_name, :attributes, attribute_name, :description)
        end

        def i18n_association_description(association_definition)
          api_class = @contract_param.contract_class.api_class
          return nil unless api_class

          schema_name = association_definition.schema_class_name
          association_name = association_definition.name

          api_class.structure.i18n_lookup(:schemas, schema_name, :associations, association_name, :description)
        end

        def scope_for_enum(definition, _enum_name)
          definition.contract_class
        end

        def qualified_name(type_name, definition)
          return type_name if global_type?(type_name, definition)
          return type_name if global_enum?(type_name, definition)
          return type_name if imported_type?(type_name, definition)

          scope = definition.contract_class
          api_class = definition.contract_class.api_class
          api_class.scoped_name(scope, type_name)
        end

        def global_type?(type_name, definition)
          return false unless definition.contract_class.respond_to?(:api_class)

          api_class = definition.contract_class.api_class
          return false unless api_class

          metadata = api_class.type_system.type_metadata(type_name)
          return false unless metadata

          metadata[:scope].nil?
        end

        def global_enum?(enum_name, definition)
          return false unless definition.contract_class.respond_to?(:api_class)

          api_class = definition.contract_class.api_class
          return false unless api_class

          metadata = api_class.type_system.enum_metadata(enum_name)
          return false unless metadata

          metadata[:scope].nil?
        end

        def imported_type?(type_name, definition)
          return false unless definition.contract_class.respond_to?(:imports)

          import_prefixes = import_prefix_cache(definition.contract_class)

          return true if import_prefixes[:direct].include?(type_name)

          type_name = type_name.to_s
          import_prefixes[:prefixes].any? { |prefix| type_name.start_with?(prefix) }
        end

        def import_prefix_cache(contract_class)
          @import_prefix_cache[contract_class] ||= begin
            direct = Set.new(contract_class.imports.keys)
            { direct:, prefixes: contract_class.imports.keys.map { |alias_name| "#{alias_name}_" } }
          end
        end
      end
    end
  end
end
