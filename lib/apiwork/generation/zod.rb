# frozen_string_literal: true

module Apiwork
  module Generation
    # Zod schema generator using API introspection
    #
    # Generates TypeScript Zod schemas from API introspection data.
    # Uses contract-based type system instead of schema introspection.
    #
    # @example Generate Zod schemas
    #   generator = Zod.new('/api/v1')
    #   schemas = generator.generate
    #   File.write('schemas.ts', schemas)
    class Zod < Base
      generator_name :zod
      content_type 'text/plain; charset=utf-8'

      def self.file_extension
        '.ts'
      end

      # Generate complete TypeScript document with Zod schemas
      #
      # @return [String] TypeScript document content
      def generate
        parts = []

        # 1. Imports
        parts << "import { z } from 'zod';\n"

        # 2. Enum schemas
        enum_schemas = build_enum_schemas
        if enum_schemas.present?
          parts << enum_schemas
          parts << ''
        end

        # 3. Type schemas from introspect
        type_schemas = build_type_schemas
        if type_schemas.present?
          parts << type_schemas
          parts << ''
        end

        parts.join("\n")
      end

      private

      # Map contract type to Zod type
      TYPE_MAP = {
        string: 'z.string()',
        text: 'z.string()',
        uuid: 'z.string().uuid()',
        integer: 'z.number().int()',
        float: 'z.number()',
        decimal: 'z.number()',
        number: 'z.number()',
        boolean: 'z.boolean()',
        date: 'z.string().date()',
        datetime: 'z.string().datetime()',
        time: 'z.string().time()',
        json: 'z.record(z.string(), z.any())',
        binary: 'z.string()'
      }.freeze

      # Build enum schemas from introspect data
      def build_enum_schemas
        return '' if enums.empty?

        enum_value_schemas = enums.map do |enum_name, enum_values|
          schema_name = zod_type_name(enum_name)
          values_str = enum_values.map { |v| "'#{v}'" }.join(', ')
          "export const #{schema_name}Schema = z.enum([#{values_str}]);"
        end.join("\n")

        enum_filter_schemas = enums.map do |enum_name, _enum_values|
          schema_name = zod_type_name(enum_name)
          <<~TYPESCRIPT.strip
            export const #{schema_name}FilterSchema = z.union([
              #{schema_name}Schema,
              z.object({
                #{transform_key('eq')}: #{schema_name}Schema.optional(),
                in: z.array(#{schema_name}Schema).optional()
              })
            ]);
          TYPESCRIPT
        end.join("\n\n")

        [enum_value_schemas, enum_filter_schemas].reject(&:empty?).join("\n\n")
      end

      # Build schemas for all types from introspect
      def build_type_schemas
        types.map do |type_name, type_shape|
          # Detect if this is an update payload type
          action_name = type_name.to_s.end_with?('_update_payload') ? 'update' : nil
          build_object_schema(type_name, type_shape, action_name)
        end.join("\n\n")
      end

      # Build Zod object schema from type shape
      def build_object_schema(type_name, type_shape, action_name = nil)
        schema_name = zod_type_name(type_name)

        properties = type_shape.map do |property_name, property_def|
          key = transform_key(property_name)
          zod_type = map_field_definition(property_def, action_name)
          "  #{key}: #{zod_type}"
        end.join(",\n")

        schema_def = "export const #{schema_name}Schema = z.object({\n#{properties}\n});"
        type_export = "export type #{schema_name} = z.infer<typeof #{schema_name}Schema>;"

        [schema_def, type_export].join("\n")
      end

      # Map field definition to Zod type
      def map_field_definition(definition, action_name = nil)
        return 'z.string()' unless definition.is_a?(Hash)

        # Handle custom type references
        if definition[:type].is_a?(Symbol) && types.key?(definition[:type])
          schema_name = zod_type_name(definition[:type])
          type = "#{schema_name}Schema"
          return apply_modifiers(type, definition, action_name)
        end

        # Map inline type
        type = map_type_definition(definition, action_name)

        # Handle enum
        if definition[:enum]
          enum_ref = resolve_enum(definition[:enum])
          if enum_ref.is_a?(Symbol) && enums.key?(enum_ref)
            enum_name = zod_type_name(enum_ref)
            type = "#{enum_name}Schema"
          elsif enum_ref.is_a?(Array)
            values_str = enum_ref.map { |v| "'#{v}'" }.join(', ')
            type = "z.enum([#{values_str}])"
          end
        end

        apply_modifiers(type, definition, action_name)
      end

      # Map type definition to Zod schema
      def map_type_definition(definition, action_name = nil)
        type = definition[:type]

        case type
        when :object
          map_object_type(definition, action_name)
        when :array
          map_array_type(definition, action_name)
        when :union
          map_union_type(definition, action_name)
        when :literal
          map_literal_type(definition)
        else
          # Primitive or custom type reference
          if types.key?(type)
            schema_name = zod_type_name(type)
            "#{schema_name}Schema"
          else
            map_primitive(type)
          end
        end
      end

      # Map object type to Zod schema (inline)
      def map_object_type(definition, action_name = nil)
        return 'z.object({})' unless definition[:shape]

        properties = definition[:shape].map do |property_name, property_def|
          key = transform_key(property_name)
          zod_type = map_field_definition(property_def, action_name)
          "#{key}: #{zod_type}"
        end.join(', ')

        "z.object({ #{properties} })"
      end

      # Map array type to Zod schema
      def map_array_type(definition, action_name = nil)
        items_type = definition[:of]
        return 'z.array(z.string())' unless items_type

        if items_type.is_a?(Symbol) && types.key?(items_type)
          schema_name = zod_type_name(items_type)
          "z.array(#{schema_name}Schema)"
        elsif items_type.is_a?(Hash)
          items_schema = map_type_definition(items_type, action_name)
          "z.array(#{items_schema})"
        else
          primitive = map_primitive(items_type)
          "z.array(#{primitive})"
        end
      end

      # Map union type to Zod union
      def map_union_type(definition, action_name = nil)
        if definition[:discriminator]
          map_discriminated_union(definition, action_name)
        else
          variants = definition[:variants].map { |variant| map_type_definition(variant, action_name) }
          "z.union([#{variants.join(', ')}])"
        end
      end

      # Map discriminated union to Zod discriminatedUnion
      def map_discriminated_union(definition, action_name = nil)
        discriminator_field = transform_key(definition[:discriminator])
        variants = definition[:variants]

        # Build array of variant schemas
        variant_schemas = variants.map { |variant| map_type_definition(variant, action_name) }

        "z.discriminatedUnion('#{discriminator_field}', [#{variant_schemas.join(', ')}])"
      end

      # Map literal type to Zod literal
      def map_literal_type(definition)
        value = definition[:value]
        case value
        when String
          "z.literal('#{value}')"
        when Integer, Float
          "z.literal(#{value})"
        when TrueClass, FalseClass
          "z.literal(#{value})"
        when NilClass
          'z.null()'
        else
          "z.literal('#{value}')"
        end
      end

      # Map primitive type to Zod type
      def map_primitive(type)
        TYPE_MAP[type.to_sym] || 'z.string()'
      end

      # Apply nullable and optional modifiers
      def apply_modifiers(type, definition, action_name)
        is_update = action_name.to_s == 'update'

        # Add nullable if specified
        type += '.nullable()' if definition[:nullable]

        # Add optional based on context
        if is_update
          # Update actions: all fields optional
          type += '.optional()' unless type.include?('.optional()')
        elsif !definition[:required]
          # Regular fields: optional if not required
          type += '.optional()'
        end

        type
      end

      # Convert type name to Zod schema name (PascalCase)
      def zod_type_name(name)
        # Use transform_key with :camelize to get PascalCase
        Transform::Case.string(name, :camelize_upper)
      end

      # Resolve enum reference
      def resolve_enum(enum_ref)
        enum_ref
      end
    end
  end
end
