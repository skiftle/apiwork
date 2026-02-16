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
                              { reference: success_type, type: :reference }
                            else
                              { reference: nil, shape: build_success_params, type: :object }
                            end

          error_variant = if error_type
                            { reference: error_type, type: :reference }
                          else
                            { reference: nil, shape: {}, type: :object }
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

          reference = resolve_type_reference(options[:type])

          {
            reference:,
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
            type: reference ? :reference : (options[:type] || :unknown),
            value: options[:type] == :literal ? options[:value] : nil,
            variants: [],
          }
        end

        def build_union_param(options)
          union_dump = build_union(options[:union])

          {
            as: options[:as],
            default: options[:default],
            deprecated: options[:deprecated] == true,
            description: resolve_attribute_description(options),
            discriminator: union_dump[:discriminator],
            enum: nil,
            example: options[:example],
            format: options[:format],
            max: nil,
            min: nil,
            nullable: options[:nullable] == true,
            of: nil,
            optional: options[:optional] == true,
            partial: false,
            reference: nil,
            shape: {},
            tag: nil,
            type: :union,
            value: nil,
            variants: union_dump[:variants],
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
            reference: custom_type_name,
            shape: {},
            tag: nil,
            type: :reference,
            value: nil,
            variants: [],
          }
        end

        def resolve_type_reference(type_value)
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
            scope = @contract_param.contract_class
            api_class = @contract_param.contract_class.api_class
            api_class.scoped_enum_name(scope, options[:enum])
          else
            options[:enum]
          end
        end

        def resolve_of(options)
          return nil unless options[:of]

          of = options[:of]

          if of.is_a?(Element)
            build_of_from_element(of, shape: options[:shape])
          elsif registered_type?(of)
            reference_name = qualified_name(of, @contract_param)
            { reference: reference_name, shape: {}, type: :reference }
          elsif of.is_a?(Symbol) && imported_type?(of, @contract_param)
            { reference: of, shape: {}, type: :reference }
          else
            build_of_from_symbol(of, shape: options[:shape])
          end
        end

        def build_of_from_element(element, shape: nil)
          type_value = element.type
          reference = registered_type?(type_value) ? qualified_name(type_value, @contract_param) : nil

          resolved_shape = if shape
                             build_nested_shape(shape)
                           elsif element.shape
                             build_nested_shape(element.shape)
                           else
                             {}
                           end

          result = {
            reference:,
            enum: element.enum,
            format: element.format,
            max: element.max,
            min: element.min,
            shape: resolved_shape,
            type: reference ? :reference : type_value,
          }

          result[:of] = build_of_from_element(element.inner) if element.type == :array && element.inner

          result
        end

        def build_of_from_symbol(type_symbol, shape: nil)
          result = { reference: nil, type: type_symbol }
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

          reference = is_registered ? qualified_name(variant_type, @contract_param) : nil
          resolved_type = is_registered ? :reference : (variant[:type] || :unknown)

          {
            reference:,
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
            scope = @contract_param.contract_class
            api_class = @contract_param.contract_class.api_class
            api_class.scoped_enum_name(scope, variant[:enum])
          else
            variant[:enum]
          end
        end

        def resolve_variant_of(variant)
          return nil unless variant[:of]

          of = variant[:of]

          if of.is_a?(Element)
            build_of_from_element(of, shape: variant[:shape])
          elsif registered_type?(of)
            reference_name = qualified_name(of, @contract_param)
            { reference: reference_name, shape: {}, type: :reference }
          else
            build_of_from_symbol(of)
          end
        end

        def resolve_variant_shape(variant, variant_type)
          if variant[:shape]
            build_nested_shape(variant[:shape])
          else
            {}
          end
        end

        def build_nested_shape(shape)
          if shape.is_a?(Apiwork::API::Object)
            dump_api_object(shape)
          elsif shape.is_a?(Apiwork::API::Union)
            dump_api_union(shape)
          else
            Param.new(shape, visited: @visited).to_h
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
            reference: nil,
            shape: options[:shape] ? build_nested_shape(options[:shape]) : {},
            tag: nil,
            type: options[:type] || :unknown,
            value: options[:type] == :literal ? options[:value] : nil,
            variants: [],
          }
        end

        def build_api_of(options)
          return nil unless options[:of]

          of = options[:of]
          if of.is_a?(Element)
            result = {
              enum: of.enum,
              format: of.format,
              max: of.max,
              min: of.min,
              reference: nil,
              shape: of.shape ? build_nested_shape(of.shape) : {},
              type: of.type,
            }
            result[:of] = build_api_of({ of: of.inner }) if of.type == :array && of.inner
            result
          else
            { reference: nil, shape: {}, type: of }
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
            of: build_api_variant_of(variant),
            optional: false,
            partial: variant[:partial] == true,
            reference: nil,
            shape: variant[:shape] ? build_nested_shape(variant[:shape]) : {},
            tag: variant[:tag],
            type: variant[:type] || :object,
            value: variant[:value],
            variants: [],
          }
        end

        def build_api_variant_of(variant)
          return nil unless variant[:of]

          of = variant[:of]
          if of.is_a?(Element)
            result = {
              enum: of.enum,
              format: of.format,
              max: of.max,
              min: of.min,
              reference: nil,
              shape: of.shape ? build_nested_shape(of.shape) : {},
              type: of.type,
            }
            result[:of] = build_api_variant_of({ of: of.inner }) if of.type == :array && of.inner
            result
          else
            { reference: nil, shape: {}, type: of }
          end
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

          representation_class = @contract_param.contract_class.representation_class
          return nil unless representation_class

          if (attribute = representation_class.attributes[param_name])
            description = i18n_attribute_description(attribute)
            return description if description
          end

          if (association = representation_class.associations[param_name])
            description = i18n_association_description(association)
            return description if description
          end

          nil
        end

        def i18n_attribute_description(attribute)
          api_class = @contract_param.contract_class.api_class
          return nil unless api_class

          representation_name = attribute.representation_class_name
          attribute_name = attribute.name

          api_class.translate(:representations, representation_name, :attributes, attribute_name, :description)
        end

        def i18n_association_description(association)
          api_class = @contract_param.contract_class.api_class
          return nil unless api_class

          representation_name = association.representation_class_name
          association_name = association.name

          api_class.translate(:representations, representation_name, :associations, association_name, :description)
        end

        def qualified_name(type_name, contract_param)
          return type_name if global_type?(type_name, contract_param)
          return type_name if global_enum?(type_name, contract_param)
          return type_name if imported_type?(type_name, contract_param)

          scope = contract_param.contract_class
          api_class = contract_param.contract_class.api_class
          api_class.scoped_type_name(scope, type_name)
        end

        def global_type?(type_name, contract_param)
          api_class = contract_param.contract_class.api_class
          return false unless api_class

          type_definition = api_class.type_registry[type_name]
          return false unless type_definition

          type_definition.scope.nil?
        end

        def global_enum?(enum_name, contract_param)
          api_class = contract_param.contract_class.api_class
          return false unless api_class

          enum_definition = api_class.enum_registry[enum_name]
          return false unless enum_definition

          enum_definition.scope.nil?
        end

        def imported_type?(type_name, contract_param)
          import_prefixes = import_prefix_cache(contract_param.contract_class)

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
