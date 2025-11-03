# frozen_string_literal: true

module Apiwork
  module Contract
    # Unified schema builder that converts Contract definitions to various formats
    # (OpenAPI, Transport, Zod)
    class SchemaBuilder
      attr_reader :definition, :options

      def initialize(definition, **options)
        @definition = definition
        @options = options
      end

      # Build OpenAPI 3.1.x schema
      def to_openapi
        return nil unless definition

        build_openapi_schema(definition)
      end

      # Build Transport schema (for TypeScript interfaces)
      def to_transport(key_transform: :camelize_lower)
        return nil unless definition

        build_transport_schema(definition, key_transform)
      end

      # Build Zod schema (for TypeScript validation)
      def to_zod
        return nil unless definition

        build_zod_schema(definition)
      end

      private

      # OpenAPI schema builder
      def build_openapi_schema(definition)
        schema = {
          type: 'object',
          properties: {},
          required: []
        }

        definition.params.each do |name, param_options|
          schema[:properties][name.to_s] = build_openapi_property(param_options)
          schema[:required] << name.to_s if param_options[:required]
        end

        schema.delete(:required) if schema[:required].empty?
        schema
      end

      def build_openapi_property(options)
        # Handle union types
        if options[:type] == :union
          return build_openapi_union(options[:union])
        end

        # Handle custom types
        if options[:custom_type]
          return build_openapi_schema(options[:nested])
        end

        base = case options[:type]
               when :string
                 { type: 'string' }
               when :integer
                 { type: 'integer' }
               when :boolean
                 { type: 'boolean' }
               when :uuid
                 { type: 'string', format: 'uuid' }
               when :datetime
                 { type: 'string', format: 'date-time' }
               when :date
                 { type: 'string', format: 'date' }
               when :decimal, :float
                 { type: 'number', format: 'float' }
               when :object
                 if options[:nested]
                   build_openapi_schema(options[:nested])
                 else
                   { type: 'object' }
                 end
               when :array
                 items = if options[:of]
                           # Check if 'of' is a custom type
                           if definition.contract_class.custom_types&.key?(options[:of])
                             custom_type_block = definition.contract_class.custom_types[options[:of]]
                             custom_def = Definition.new(definition.type, definition.contract_class)
                             custom_def.instance_eval(&custom_type_block)
                             build_openapi_schema(custom_def)
                           else
                             build_openapi_property(type: options[:of])
                           end
                         elsif options[:nested]
                           build_openapi_schema(options[:nested])
                         else
                           { type: 'object' }
                         end
                 { type: 'array', items: }
               else
                 { type: 'string' }
               end

        base[:enum] = options[:enum] if options[:enum]
        base[:description] = options[:description] if options[:description]
        base[:default] = options[:default] if options[:default]

        base
      end

      # Build OpenAPI oneOf for union type
      def build_openapi_union(union_def)
        variants = union_def.variants.map do |variant_def|
          build_openapi_variant(variant_def)
        end

        { oneOf: variants }
      end

      # Build OpenAPI schema for a single variant
      def build_openapi_variant(variant_def)
        type = variant_def[:type]

        # Check if type is a custom type
        if definition.contract_class.custom_types&.key?(type)
          custom_type_block = definition.contract_class.custom_types[type]
          custom_def = Definition.new(definition.type, definition.contract_class)
          custom_def.instance_eval(&custom_type_block)
          return build_openapi_schema(custom_def)
        end

        # Handle nested object variant
        if variant_def[:nested]
          return build_openapi_schema(variant_def[:nested])
        end

        # Handle array variant
        if type == :array
          items = if variant_def[:of]
                    # Check if 'of' is a custom type
                    if definition.contract_class.custom_types&.key?(variant_def[:of])
                      custom_type_block = definition.contract_class.custom_types[variant_def[:of]]
                      custom_def = Definition.new(definition.type, definition.contract_class)
                      custom_def.instance_eval(&custom_type_block)
                      build_openapi_schema(custom_def)
                    else
                      build_openapi_property(type: variant_def[:of])
                    end
                  elsif variant_def[:nested]
                    build_openapi_schema(variant_def[:nested])
                  else
                    { type: 'object' }
                  end
          return { type: 'array', items: }
        end

        # Handle primitive type variant
        property = build_openapi_property(type: type)
        property[:enum] = variant_def[:enum] if variant_def[:enum]
        property
      end

      # Transport schema builder
      def build_transport_schema(definition, key_transform)
        schema = {
          type: 'object',
          properties: {}
        }

        definition.params.each do |name, param_options|
          transformed_key = transform_key(name.to_s, key_transform)
          schema[:properties][transformed_key] = build_transport_property(param_options, key_transform)
        end

        schema
      end

      def build_transport_property(options, key_transform)
        # Handle union types
        if options[:type] == :union
          return build_transport_union(options[:union], options[:required], key_transform)
        end

        # Handle custom types
        if options[:custom_type]
          schema = build_transport_schema(options[:nested], key_transform)
          schema[:optional] = !options[:required]
          return schema
        end

        base = case options[:type]
               when :string
                 { type: 'string' }
               when :integer
                 { type: 'number' }
               when :boolean
                 { type: 'boolean' }
               when :uuid
                 { type: 'string', format: 'uuid' }
               when :datetime
                 { type: 'string', format: 'date-time' }
               when :date
                 { type: 'string', format: 'date' }
               when :decimal, :float
                 { type: 'number' }
               when :object
                 if options[:nested]
                   build_transport_schema(options[:nested], key_transform)
                 else
                   { type: 'object' }
                 end
               when :array
                 items = if options[:of]
                           # Check if 'of' is a custom type
                           if definition.contract_class.custom_types&.key?(options[:of])
                             custom_type_block = definition.contract_class.custom_types[options[:of]]
                             custom_def = Definition.new(definition.type, definition.contract_class)
                             custom_def.instance_eval(&custom_type_block)
                             build_transport_schema(custom_def, key_transform)
                           else
                             build_transport_property({ type: options[:of] }, key_transform)
                           end
                         elsif options[:nested]
                           build_transport_schema(options[:nested], key_transform)
                         else
                           { type: 'object' }
                         end
                 { type: 'array', items: }
               else
                 { type: 'string' }
               end

        base[:enum] = options[:enum] if options[:enum]
        base[:optional] = !options[:required]

        base
      end

      # Build Transport union for union type
      def build_transport_union(union_def, required, key_transform)
        variants = union_def.variants.map do |variant_def|
          build_transport_variant(variant_def, key_transform)
        end

        {
          type: 'union',
          variants: variants,
          optional: !required
        }
      end

      # Build Transport schema for a single variant
      def build_transport_variant(variant_def, key_transform)
        type = variant_def[:type]

        # Check if type is a custom type
        if definition.contract_class.custom_types&.key?(type)
          custom_type_block = definition.contract_class.custom_types[type]
          custom_def = Definition.new(definition.type, definition.contract_class)
          custom_def.instance_eval(&custom_type_block)
          return build_transport_schema(custom_def, key_transform)
        end

        # Handle nested object variant
        if variant_def[:nested]
          return build_transport_schema(variant_def[:nested], key_transform)
        end

        # Handle array variant
        if type == :array
          items = if variant_def[:of]
                    # Check if 'of' is a custom type
                    if definition.contract_class.custom_types&.key?(variant_def[:of])
                      custom_type_block = definition.contract_class.custom_types[variant_def[:of]]
                      custom_def = Definition.new(definition.type, definition.contract_class)
                      custom_def.instance_eval(&custom_type_block)
                      build_transport_schema(custom_def, key_transform)
                    else
                      build_transport_property({ type: variant_def[:of] }, key_transform)
                    end
                  elsif variant_def[:nested]
                    build_transport_schema(variant_def[:nested], key_transform)
                  else
                    { type: 'object' }
                  end
          return { type: 'array', items: items }
        end

        # Handle primitive type variant
        property = build_transport_property({ type: type }, key_transform)
        property[:enum] = variant_def[:enum] if variant_def[:enum]
        property
      end

      # Zod schema builder
      def build_zod_schema(definition)
        parts = definition.params.map do |name, param_options|
          "  #{name}: #{build_zod_property(param_options)}"
        end

        "z.object({\n#{parts.join(",\n")}\n})"
      end

      def build_zod_property(options)
        # Handle union types
        if options[:type] == :union
          return build_zod_union(options[:union], options[:required])
        end

        # Handle custom types
        if options[:custom_type]
          base = build_zod_schema(options[:nested])
          base += '.optional()' unless options[:required]
          base += ".default(#{options[:default].inspect})" if options[:default]
          return base
        end

        base = case options[:type]
               when :string
                 if options[:enum]
                   "z.enum([#{options[:enum].map { |v| "'#{v}'" }.join(', ')}])"
                 else
                   'z.string()'
                 end
               when :integer
                 'z.number().int()'
               when :boolean
                 'z.boolean()'
               when :uuid
                 'z.string().uuid()'
               when :datetime
                 'z.string().datetime()'
               when :date
                 'z.string().date()'
               when :decimal, :float
                 'z.number()'
               when :object
                 if options[:nested]
                   build_zod_schema(options[:nested])
                 else
                   'z.object({})'
                 end
               when :array
                 items = if options[:of]
                           # Check if 'of' is a custom type
                           if definition.contract_class.custom_types&.key?(options[:of])
                             custom_type_block = definition.contract_class.custom_types[options[:of]]
                             custom_def = Definition.new(definition.type, definition.contract_class)
                             custom_def.instance_eval(&custom_type_block)
                             build_zod_schema(custom_def)
                           else
                             build_zod_property(type: options[:of])
                           end
                         elsif options[:nested]
                           build_zod_schema(options[:nested])
                         else
                           'z.object({})'
                         end
                 "z.array(#{items})"
               else
                 'z.string()'
               end

        base += '.optional()' unless options[:required]
        base += ".default(#{options[:default].inspect})" if options[:default]

        base
      end

      # Build Zod union for union type
      def build_zod_union(union_def, required)
        variants = union_def.variants.map do |variant_def|
          build_zod_variant(variant_def)
        end

        base = "z.union([#{variants.join(', ')}])"
        base += '.optional()' unless required
        base
      end

      # Build Zod schema for a single variant
      def build_zod_variant(variant_def)
        type = variant_def[:type]

        # Check if type is a custom type
        if definition.contract_class.custom_types&.key?(type)
          custom_type_block = definition.contract_class.custom_types[type]
          custom_def = Definition.new(definition.type, definition.contract_class)
          custom_def.instance_eval(&custom_type_block)
          return build_zod_schema(custom_def)
        end

        # Handle nested object variant
        if variant_def[:nested]
          return build_zod_schema(variant_def[:nested])
        end

        # Handle array variant
        if type == :array
          items = if variant_def[:of]
                    # Check if 'of' is a custom type
                    if definition.contract_class.custom_types&.key?(variant_def[:of])
                      custom_type_block = definition.contract_class.custom_types[variant_def[:of]]
                      custom_def = Definition.new(definition.type, definition.contract_class)
                      custom_def.instance_eval(&custom_type_block)
                      build_zod_schema(custom_def)
                    else
                      build_zod_property(type: variant_def[:of])
                    end
                  elsif variant_def[:nested]
                    build_zod_schema(variant_def[:nested])
                  else
                    'z.object({})'
                  end
          return "z.array(#{items})"
        end

        # Handle primitive type variant
        # If enum is present, use z.enum instead of the type
        if variant_def[:enum]
          return "z.enum([#{variant_def[:enum].map { |v| "'#{v}'" }.join(', ')}])"
        end

        build_zod_property(type: type)
      end

      # Key transformation helper
      def transform_key(key, key_transform)
        case key_transform
        when :camelize_lower
          key.camelize(:lower)
        when :camelize_upper
          key.camelize
        when :underscore
          key.underscore
        when :dasherize
          key.dasherize
        when :none
          key
        else
          key
        end
      end
    end
  end
end
