# frozen_string_literal: true

module Apiwork
  module Introspection
    module Dump
      class Type
        def initialize(api_class)
          @api_class = api_class
        end

        def to_h
          {
            enums: enums,
            types: types,
          }
        end

        def types
          @api_class.type_registry.each_pair.sort_by { |name, _definition| name.to_s }.each_with_object({}) do |(qualified_name, definition), result|
            result[qualified_name] = build_type(qualified_name, definition)
          end
        end

        def enums
          @api_class.enum_registry.each_pair.sort_by { |name, _definition| name.to_s }.each_with_object({}) do |(qualified_name, definition), result|
            result[qualified_name] = build_enum(qualified_name, definition)
          end
        end

        def build_type(qualified_name, definition)
          if definition.union?
            {
              deprecated: definition.deprecated?,
              description: resolve_type_description(qualified_name, definition),
              discriminator: definition.discriminator,
              example: definition.example || definition.schema_class&.example,
              format: definition.format,
              shape: {},
              type: :union,
              variants: build_variants(definition),
            }
          else
            {
              deprecated: definition.deprecated?,
              description: resolve_type_description(qualified_name, definition),
              discriminator: nil,
              example: definition.example || definition.schema_class&.example,
              format: definition.format,
              shape: build_params(definition),
              type: :object,
              variants: [],
            }
          end
        end

        def build_params(definition)
          return {} unless definition.params

          result = {}
          definition.params.sort_by { |name, _| name.to_s }.each do |name, param_options|
            result[name] = build_param(name, param_options, definition.scope)
          end
          result
        end

        def build_variants(definition)
          return [] unless definition.variants

          definition.variants.map do |variant|
            build_variant(variant, definition.scope)
          end
        end

        def build_param(name, options, scope)
          ref = resolve_type_ref(options[:type], scope)

          {
            ref:,
            as: options[:as],
            default: options[:default],
            deprecated: options[:deprecated] == true,
            description: options[:description],
            discriminator: nil,
            enum: resolve_enum(options, scope),
            example: options[:example],
            format: options[:format],
            max: options[:max],
            min: options[:min],
            nullable: options[:nullable] == true,
            of: resolve_of(options, scope),
            optional: options[:optional] == true,
            partial: options[:partial] == true,
            shape: build_nested_shape(options[:shape]),
            tag: nil,
            type: ref ? :ref : (options[:type] || :unknown),
            value: options[:type] == :literal ? options[:value] : nil,
            variants: build_nested_variants(options[:shape]),
          }
        end

        def build_variant(variant, scope)
          variant_type = variant[:custom_type] || variant[:type]
          is_registered = registered_type?(variant_type)

          ref = is_registered ? variant_type : nil
          resolved_type = is_registered ? :ref : (variant[:type] || :unknown)

          {
            ref:,
            as: nil,
            default: nil,
            deprecated: false,
            description: nil,
            discriminator: nil,
            enum: resolve_variant_enum(variant, scope),
            example: nil,
            format: nil,
            max: nil,
            min: nil,
            nullable: false,
            of: resolve_variant_of(variant, scope),
            optional: false,
            partial: variant[:partial] == true,
            shape: build_nested_shape(variant[:shape]),
            tag: variant[:tag],
            type: resolved_type,
            value: variant[:value],
            variants: [],
          }
        end

        def build_nested_shape(shape)
          return {} unless shape
          return {} unless shape.respond_to?(:params)

          result = {}
          shape.params.sort_by { |name, _| name.to_s }.each do |name, param_options|
            result[name] = build_param(name, param_options, nil)
          end
          result
        end

        def build_nested_variants(shape)
          return [] unless shape
          return [] unless shape.respond_to?(:variants)

          shape.variants.map { |v| build_variant(v, nil) }
        end

        def resolve_type_ref(type_value, scope)
          return nil unless type_value

          resolve_scoped_type_name(type_value, scope)
        end

        def resolve_enum(options, scope)
          return nil unless options[:enum]

          if options[:enum].is_a?(Symbol)
            @api_class.scoped_enum_name(scope, options[:enum])
          else
            options[:enum]
          end
        end

        def resolve_of(options, scope)
          return nil unless options[:of]

          of_value = options[:of]

          if of_value.is_a?(Hash)
            type_value = of_value[:type]
            scoped_name = resolve_scoped_type_name(type_value, scope)
            {
              enum: of_value[:enum],
              format: of_value[:format],
              max: of_value[:max],
              min: of_value[:min],
              ref: scoped_name,
              shape: {},
              type: scoped_name ? :ref : type_value,
            }
          else
            scoped_name = resolve_scoped_type_name(of_value, scope)
            if scoped_name
              { ref: scoped_name, shape: {}, type: :ref }
            else
              { ref: nil, shape: {}, type: of_value }
            end
          end
        end

        def resolve_variant_enum(variant, scope)
          return nil unless variant[:enum]

          if variant[:enum].is_a?(Symbol)
            @api_class.scoped_enum_name(scope, variant[:enum])
          else
            variant[:enum]
          end
        end

        def resolve_variant_of(variant, scope)
          return nil unless variant[:of]

          of_value = variant[:of]

          if of_value.is_a?(Hash)
            type_value = of_value[:type]
            scoped_name = resolve_scoped_type_name(type_value, scope)
            {
              enum: of_value[:enum],
              format: of_value[:format],
              max: of_value[:max],
              min: of_value[:min],
              ref: scoped_name,
              shape: {},
              type: scoped_name ? :ref : type_value,
            }
          else
            scoped_name = resolve_scoped_type_name(of_value, scope)
            if scoped_name
              { ref: scoped_name, shape: {}, type: :ref }
            else
              { ref: nil, shape: {}, type: of_value }
            end
          end
        end

        def build_enum(qualified_name, definition)
          {
            deprecated: definition.deprecated?,
            description: resolve_enum_description(qualified_name, definition),
            example: definition.example,
            values: definition.values || [],
          }
        end

        private

        def resolve_type_description(type_name, definition)
          return definition.description if definition.description

          if definition.schema_class.respond_to?(:description)
            schema_description = definition.schema_class.description
            return schema_description if schema_description
          end

          result = @api_class.structure.i18n_lookup(:types, type_name, :description)
          return result if result

          I18n.t(:"apiwork.types.#{type_name}.description", default: nil)
        end

        def resolve_enum_description(enum_name, definition)
          return definition.description if definition.description

          result = @api_class.structure.i18n_lookup(:enums, enum_name, :description)
          return result if result

          I18n.t(:"apiwork.enums.#{enum_name}.description", default: nil)
        end

        def resolve_scoped_type_name(type_name, scope)
          return nil unless type_name.is_a?(Symbol)
          return nil unless @api_class

          return type_name if @api_class.type_registry.key?(type_name) || @api_class.enum_registry.key?(type_name)

          return nil unless scope

          scoped_name = @api_class.scoped_type_name(scope, type_name)
          return scoped_name if @api_class.type_registry.key?(scoped_name) || @api_class.enum_registry.key?(scoped_name)

          nil
        end

        def registered_type?(type_name)
          return false unless type_name.is_a?(Symbol)
          return false unless @api_class

          @api_class.type_registry.key?(type_name) || @api_class.enum_registry.key?(type_name)
        end
      end
    end
  end
end
