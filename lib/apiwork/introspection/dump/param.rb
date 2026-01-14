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

          scoped_name = api_class.scoped_type_name(contract_class, type_value)
          return true if api_class.type_registry.key?(scoped_name) || api_class.type_registry.key?(type_value)
          return true if api_class.enum_registry.key?(scoped_name) || api_class.enum_registry.key?(type_value)

          false
        end

        def resolve_enum(options)
          return nil unless options[:enum]

          if options[:enum].is_a?(Symbol)
            scope = scope_for_enum(@contract_param, options[:enum])
            api_class = @contract_param.contract_class.api_class
            api_class.scoped_enum_name(scope, options[:enum])
          else
            options[:enum]
          end
        end

        def resolve_of(options)
          return nil unless options[:of]

          of_value = options[:of]

          if of_value.is_a?(Hash)
            build_of_from_hash(of_value, shape: options[:shape])
          elsif registered_type?(of_value)
            ref_name = qualified_name(of_value, @contract_param)
            { ref: ref_name, shape: {}, type: :ref }
          else
            build_of_from_symbol(of_value, shape: options[:shape])
          end
        end

        def build_of_from_hash(of_hash, shape: nil)
          type_value = of_hash[:type]
          ref = registered_type?(type_value) ? qualified_name(type_value, @contract_param) : nil

          resolved_shape = shape ? build_nested_shape(shape) : {}

          {
            ref:,
            enum: of_hash[:enum],
            format: of_hash[:format],
            max: of_hash[:max],
            min: of_hash[:min],
            shape: resolved_shape,
            type: ref ? :ref : type_value,
          }
        end

        def build_of_from_symbol(type_symbol, shape: nil)
          result = { ref: nil, type: type_symbol }
          if [:object, :array].include?(type_symbol)
            result[:shape] = shape ? build_nested_shape(shape) : {}
          end
          result
        end

        def build_union(union)
          {
            discriminator: union.discriminator,
            variants: union.variants.map { |variant| build_variant(variant) },
          }
        end

        def build_variant(variant)
          variant_type = variant[:custom_type] || variant[:type]
          is_registered = registered_type?(variant_type)

          ref = is_registered ? qualified_name(variant_type, @contract_param) : nil
          resolved_type = is_registered ? :ref : (variant[:type] || :unknown)

          {
            ref:,
            as: nil,
            default: nil,
            deprecated: false,
            description: nil,
            discriminator: nil,
            enum: resolve_variant_enum(variant),
            example: nil,
            format: nil,
            max: nil,
            min: nil,
            nullable: false,
            of: resolve_variant_of(variant),
            optional: false,
            partial: variant[:partial] == true,
            shape: resolve_variant_shape(variant, variant_type),
            tag: variant[:tag],
            type: resolved_type,
            value: variant[:value],
            variants: [],
          }
        end

        def resolve_variant_enum(variant)
          return nil unless variant[:enum]

          if variant[:enum].is_a?(Symbol)
            if @contract_param.contract_class.respond_to?(:schema_class) &&
               @contract_param.contract_class.schema_class
              scope = scope_for_enum(@contract_param, variant[:enum])
              api_class = @contract_param.contract_class.api_class
              api_class.scoped_enum_name(scope, variant[:enum])
            else
              variant[:enum]
            end
          else
            variant[:enum]
          end
        end

        def resolve_variant_of(variant)
          return nil unless variant[:of]

          if registered_type?(variant[:of])
            ref_name = qualified_name(variant[:of], @contract_param)
            { ref: ref_name, shape: {}, type: :ref }
          else
            build_of_from_symbol(variant[:of])
          end
        end

        def resolve_variant_shape(variant, variant_type)
          if variant[:shape]
            build_nested_shape(variant[:shape])
          else
            {}
          end
        end

        def build_nested_shape(shape_definition)
          if shape_definition.is_a?(Apiwork::API::Object)
            dump_api_object(shape_definition)
          elsif shape_definition.is_a?(Apiwork::API::Union)
            dump_api_union(shape_definition)
          else
            Param.new(shape_definition, visited: @visited).to_h
          end
        end

        def dump_api_object(api_object)
          result = {}
          api_object.params.sort_by { |name, _| name.to_s }.each do |name, options|
            result[name] = build_api_param(options)
          end
          result
        end

        def dump_api_union(api_union)
          {
            discriminator: api_union.discriminator,
            variants: api_union.variants.map { |variant| build_api_variant(variant) },
          }
        end

        def build_api_param(options)
          {
            as: options[:as],
            default: options[:default],
            deprecated: options[:deprecated] == true,
            description: options[:description],
            discriminator: options[:discriminator],
            enum: options[:enum],
            example: options[:example],
            format: options[:format],
            max: options[:max],
            min: options[:min],
            nullable: options[:nullable] == true,
            of: build_api_of(options),
            optional: options[:optional] == true,
            partial: options[:partial] == true,
            ref: nil,
            shape: options[:shape] ? build_nested_shape(options[:shape]) : {},
            tag: nil,
            type: options[:type] || :unknown,
            value: options[:type] == :literal ? options[:value] : nil,
            variants: [],
          }
        end

        def build_api_of(options)
          return nil unless options[:of]

          of_value = options[:of]
          if of_value.is_a?(Hash)
            {
              enum: of_value[:enum],
              format: of_value[:format],
              max: of_value[:max],
              min: of_value[:min],
              ref: nil,
              shape: options[:shape] ? build_nested_shape(options[:shape]) : {},
              type: of_value[:type],
            }
          else
            { ref: nil, shape: {}, type: of_value }
          end
        end

        def build_api_variant(variant)
          {
            as: nil,
            default: nil,
            deprecated: false,
            description: nil,
            discriminator: nil,
            enum: variant[:enum],
            example: nil,
            format: nil,
            max: nil,
            min: nil,
            nullable: false,
            of: nil,
            optional: false,
            partial: variant[:partial] == true,
            ref: nil,
            shape: variant[:shape] ? build_nested_shape(variant[:shape]) : {},
            tag: variant[:tag],
            type: variant[:type] || :object,
            value: variant[:value],
            variants: [],
          }
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

          if (attribute = schema_class.attributes[param_name])
            description = i18n_attribute_description(attribute)
            return description if description
          end

          if (association = schema_class.associations[param_name])
            description = i18n_association_description(association)
            return description if description
          end

          nil
        end

        def resolve_schema_class
          contract_class = @contract_param.contract_class
          return contract_class.schema_class if contract_class.respond_to?(:schema_class) && contract_class.schema_class

          nil
        end

        def i18n_attribute_description(attribute)
          api_class = @contract_param.contract_class.api_class
          return nil unless api_class

          schema_name = attribute.schema_class_name
          attribute_name = attribute.name

          api_class.translate(:schemas, schema_name, :attributes, attribute_name, :description)
        end

        def i18n_association_description(association)
          api_class = @contract_param.contract_class.api_class
          return nil unless api_class

          schema_name = association.schema_class_name
          association_name = association.name

          api_class.translate(:schemas, schema_name, :associations, association_name, :description)
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
          api_class.scoped_type_name(scope, type_name)
        end

        def global_type?(type_name, definition)
          return false unless definition.contract_class.respond_to?(:api_class)

          api_class = definition.contract_class.api_class
          return false unless api_class

          type_definition = api_class.type_registry[type_name]
          return false unless type_definition

          type_definition.scope.nil?
        end

        def global_enum?(enum_name, definition)
          return false unless definition.contract_class.respond_to?(:api_class)

          api_class = definition.contract_class.api_class
          return false unless api_class

          enum_definition = api_class.enum_registry[enum_name]
          return false unless enum_definition

          enum_definition.scope.nil?
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
