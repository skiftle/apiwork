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
          @api_class.type_registry.each_pair
            .reject { |_, type_definition| type_definition.fragment? }
            .sort_by do |name, _type_definition|
              name.to_s
          end.each_with_object({}) do |(qualified_name, type_definition), result|
            result[qualified_name] = build_type(qualified_name, type_definition)
          end
        end

        def enums
          @api_class.enum_registry.each_pair.sort_by do |name, _enum_definition|
            name.to_s
          end.each_with_object({}) do |(qualified_name, enum_definition), result|
            result[qualified_name] = build_enum(qualified_name, enum_definition)
          end
        end

        def build_type(qualified_name, type_definition)
          if type_definition.union?
            {
              deprecated: type_definition.deprecated?,
              description: resolve_type_description(qualified_name, type_definition),
              discriminator: type_definition.discriminator,
              example: type_definition.example,
              extends: [],
              shape: {},
              type: :union,
              variants: build_variants(type_definition),
            }
          else
            {
              deprecated: type_definition.deprecated?,
              description: resolve_type_description(qualified_name, type_definition),
              discriminator: nil,
              example: type_definition.example,
              extends: resolve_extends(type_definition.shape.extends, type_definition.scope),
              shape: build_params(type_definition),
              type: :object,
              variants: [],
            }
          end
        end

        def resolve_extends(extends, scope)
          extends.map { |name| resolve_scoped_type_name(name, scope) || name }
        end

        def build_params(type_definition)
          return {} unless type_definition.params

          result = {}

          expand_merged_types(type_definition, result)

          type_definition.params.sort_by { |name, _| name.to_s }.each do |name, param_options|
            result[name] = build_param(name, param_options, type_definition.scope)
          end
          result
        end

        def expand_merged_types(type_definition, result)
          return unless type_definition.shape.respond_to?(:merged)

          type_definition.shape.merged.each do |merged_name|
            merged_type = @api_class.type_registry[merged_name]
            next unless merged_type&.params

            merged_type.params.each do |name, param_options|
              result[name] = build_param(name, param_options, type_definition.scope)
            end
          end
        end

        def build_variants(type_definition)
          return [] unless type_definition.variants

          type_definition.variants.map do |variant|
            build_variant(variant, type_definition.scope)
          end
        end

        def build_param(name, options, scope)
          reference = resolve_type_reference(options[:type], scope)

          {
            reference:,
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
            of: resolve_of(options, scope, shape: options[:shape]),
            optional: options[:optional] == true,
            partial: options[:partial] == true,
            shape: build_nested_shape(options[:shape]),
            tag: nil,
            type: reference ? :reference : (options[:type] || :unknown),
            value: options[:type] == :literal ? options[:value] : nil,
            variants: build_nested_variants(options[:shape]),
          }
        end

        def build_variant(variant, scope)
          reference = resolve_type_reference(variant[:custom_type] || variant[:type], scope)
          resolved_type = reference ? :reference : (variant[:type] || :unknown)

          {
            reference:,
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

          shape.variants.map { |variant| build_variant(variant, nil) }
        end

        def resolve_type_reference(type_value, scope)
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

        def resolve_of(options, scope, shape: nil)
          return nil unless options[:of]

          of = options[:of]

          if of.is_a?(Element)
            type_value = of.type
            scoped_name = resolve_scoped_type_name(type_value, scope)
            resolved_shape = if shape
                               build_nested_shape(shape)
                             elsif of.shape
                               build_nested_shape(of.shape)
                             else
                               {}
                             end
            result = {
              enum: of.enum,
              format: of.format,
              max: of.max,
              min: of.min,
              reference: scoped_name,
              shape: resolved_shape,
              type: scoped_name ? :reference : type_value,
            }
            result[:of] = resolve_of({ of: of.inner }, scope) if of.type == :array && of.inner
            result
          elsif of.is_a?(Hash)
            type_value = of[:type]
            scoped_name = resolve_scoped_type_name(type_value, scope)
            resolved_shape = shape ? build_nested_shape(shape) : {}
            {
              enum: of[:enum],
              format: of[:format],
              max: of[:max],
              min: of[:min],
              reference: scoped_name,
              shape: resolved_shape,
              type: scoped_name ? :reference : type_value,
            }
          else
            scoped_name = resolve_scoped_type_name(of, scope)
            resolved_shape = shape ? build_nested_shape(shape) : {}
            if scoped_name
              { reference: scoped_name, shape: {}, type: :reference }
            else
              { reference: nil, shape: resolved_shape, type: of }
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

          of = variant[:of]

          if of.is_a?(Element)
            type_value = of.type
            scoped_name = resolve_scoped_type_name(type_value, scope)
            resolved_shape = of.shape ? build_nested_shape(of.shape) : {}
            result = {
              enum: of.enum,
              format: of.format,
              max: of.max,
              min: of.min,
              reference: scoped_name,
              shape: resolved_shape,
              type: scoped_name ? :reference : type_value,
            }
            result[:of] = resolve_variant_of({ of: of.inner }, scope) if of.type == :array && of.inner
            result
          elsif of.is_a?(Hash)
            type_value = of[:type]
            scoped_name = resolve_scoped_type_name(type_value, scope)
            {
              enum: of[:enum],
              format: of[:format],
              max: of[:max],
              min: of[:min],
              reference: scoped_name,
              shape: {},
              type: scoped_name ? :reference : type_value,
            }
          else
            scoped_name = resolve_scoped_type_name(of, scope)
            if scoped_name
              { reference: scoped_name, shape: {}, type: :reference }
            else
              { reference: nil, shape: {}, type: of }
            end
          end
        end

        def build_enum(qualified_name, enum_definition)
          {
            deprecated: enum_definition.deprecated?,
            description: resolve_enum_description(qualified_name, enum_definition),
            example: enum_definition.example,
            values: enum_definition.values || [],
          }
        end

        private

        def resolve_type_description(type_name, type_definition)
          return type_definition.description if type_definition.description

          result = @api_class.translate(:types, type_name, :description)
          return result if result

          I18n.translate(:"apiwork.types.#{type_name}.description", default: nil)
        end

        def resolve_enum_description(enum_name, enum_definition)
          return enum_definition.description if enum_definition.description

          result = @api_class.translate(:enums, enum_name, :description)
          return result if result

          I18n.translate(:"apiwork.enums.#{enum_name}.description", default: nil)
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
