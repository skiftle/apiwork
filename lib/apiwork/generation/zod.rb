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

        # 3. TypeScript enum types
        typescript_enum_types = build_typescript_enum_types
        if typescript_enum_types.present?
          parts << typescript_enum_types
          parts << ''
        end

        # 4. TypeScript type declarations
        typescript_types = build_typescript_types
        if typescript_types.present?
          parts << typescript_types
          parts << ''
        end

        # 5. Zod schemas (referencing TypeScript types)
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
          "export const #{schema_name}Schema: z.ZodType<#{schema_name}> = z.enum([#{values_str}]);"
        end.join("\n")

        enum_filter_schemas = enums.map do |enum_name, _enum_values|
          schema_name = zod_type_name(enum_name)
          <<~TYPESCRIPT.strip
            export const #{schema_name}FilterSchema: z.ZodType<#{schema_name}Filter> = z.union([
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

      # Build TypeScript enum types from introspect data
      def build_typescript_enum_types
        return '' if enums.empty?

        # Generate TypeScript union types for enums
        enum_types = enums.map do |enum_name, enum_values|
          type_name = zod_type_name(enum_name)
          # Create a union of literal types
          values_str = enum_values.map { |v| "'#{v}'" }.join(' | ')
          "export type #{type_name} = #{values_str};"
        end.join("\n")

        # Generate TypeScript types for enum filters
        enum_filter_types = enums.map do |enum_name, _enum_values|
          type_name = zod_type_name(enum_name)
          eq_key = transform_key('eq')
          <<~TYPESCRIPT.strip
            export type #{type_name}Filter = #{type_name} | {
              #{eq_key}?: #{type_name};
              in?: #{type_name}[];
            };
          TYPESCRIPT
        end.join("\n\n")

        [enum_types, enum_filter_types].reject(&:empty?).join("\n\n")
      end

      # Build schemas for all types from introspect
      def build_type_schemas
        # Sort ALL types in topological order to avoid forward references
        sorted_types = topological_sort_types(types)

        # Generate schemas for all types
        schemas = sorted_types.map do |type_name, type_shape|
          # Detect if this is an update payload type
          action_name = type_name.to_s.end_with?('_update_payload') ? 'update' : nil
          # Check if type is recursive
          recursive = type_shape[:recursive] == true
          build_object_schema(type_name, type_shape, action_name, recursive: recursive)
        end

        schemas.join("\n\n")
      end

      # Sort types in topological order to avoid forward references
      # Types that don't depend on other types come first
      def topological_sort_types(all_types)
        # Build dependency graph
        dependencies = {}
        all_types.each do |type_name, type_shape|
          # Extract type references from this type
          refs = extract_type_references_for_sorting(type_shape, all_types.keys)
          dependencies[type_name] = refs
        end

        # Topological sort using Kahn's algorithm
        sorted = []
        in_degree = Hash.new(0)

        # Calculate in-degrees
        dependencies.each do |_type, deps|
          deps.each { |dep| in_degree[dep] += 1 }
        end

        # Start with types that have no incoming edges
        queue = dependencies.keys.select { |type| in_degree[type].zero? }

        while queue.any?
          current = queue.shift
          sorted << current

          # Remove edges from current node
          dependencies[current].each do |dep|
            in_degree[dep] -= 1
            queue << dep if in_degree[dep].zero?
          end
        end

        # If there's a cycle, just use original order
        if sorted.size != all_types.size
          all_types.to_a
        else
          sorted.map { |type_name| [type_name, all_types[type_name]] }
        end
      end

      # Extract references to other types from a type definition (for sorting)
      def extract_type_references_for_sorting(type_shape, all_type_names)
        refs = []

        type_shape.each do |key, value|
          next if key == :recursive
          next unless value.is_a?(Hash)

          # Direct type reference
          if value[:type].is_a?(Symbol) && all_type_names.include?(value[:type])
            refs << value[:type]
          end

          # Array 'of' reference
          if value[:of].is_a?(Symbol) && all_type_names.include?(value[:of])
            refs << value[:of]
          end

          # Union variant references
          if value[:variants].is_a?(Array)
            value[:variants].each do |variant|
              next unless variant.is_a?(Hash)

              if variant[:type].is_a?(Symbol) && all_type_names.include?(variant[:type])
                refs << variant[:type]
              end

              if variant[:of].is_a?(Symbol) && all_type_names.include?(variant[:of])
                refs << variant[:of]
              end
            end
          end
        end

        refs.uniq
      end

      # Build Zod object schema from type shape
      def build_object_schema(type_name, type_shape, action_name = nil, recursive: false)
        schema_name = zod_type_name(type_name)

        # Filter out the :recursive key from type_shape
        filtered_shape = type_shape.reject { |k, _v| k == :recursive }

        properties = filtered_shape.map do |property_name, property_def|
          key = transform_key(property_name)
          zod_type = map_field_definition(property_def, action_name)
          "  #{key}: #{zod_type}"
        end.join(",\n")

        if recursive
          # Recursive types use z.lazy() with TypeScript type annotation
          "export const #{schema_name}Schema: z.ZodType<#{schema_name}> = z.lazy(() => z.object({\n#{properties}\n}));"
        else
          # Non-recursive types use z.object() with TypeScript type annotation
          "export const #{schema_name}Schema: z.ZodType<#{schema_name}> = z.object({\n#{properties}\n});"
        end
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

      # Build TypeScript type declarations for all types
      def build_typescript_types
        # Sort ALL types in topological order
        sorted_types = topological_sort_types(types)

        # Generate TypeScript type/interface declarations
        type_declarations = sorted_types.map do |type_name, type_shape|
          action_name = type_name.to_s.end_with?('_update_payload') ? 'update' : nil
          recursive = type_shape[:recursive] == true
          build_typescript_type(type_name, type_shape, action_name, recursive: recursive)
        end

        type_declarations.join("\n\n")
      end

      # Build TypeScript type declaration
      def build_typescript_type(type_name, type_shape, action_name = nil, recursive: false)
        type_name_pascal = zod_type_name(type_name)
        filtered_shape = type_shape.reject { |k, _v| k == :recursive }

        properties = filtered_shape.map do |property_name, property_def|
          key = transform_key(property_name)
          is_update = action_name.to_s == 'update'
          is_optional = is_update || !property_def[:required]

          ts_type = map_typescript_field(property_def, action_name)
          optional_marker = is_optional ? '?' : ''
          "  #{key}#{optional_marker}: #{ts_type};"
        end.join("\n")

        if recursive
          # Use interface for recursive types
          "export interface #{type_name_pascal} {\n#{properties}\n}"
        else
          # Use type for non-recursive types
          "export type #{type_name_pascal} = {\n#{properties}\n};"
        end
      end

      # Map field definition to TypeScript type syntax
      def map_typescript_field(definition, action_name = nil)
        return 'string' unless definition.is_a?(Hash)

        is_nullable = definition[:nullable]

        # Handle custom type references
        if definition[:type].is_a?(Symbol) && types.key?(definition[:type])
          base_type = zod_type_name(definition[:type])
        else
          base_type = map_typescript_type_definition(definition, action_name)
        end

        # Handle enum
        if definition[:enum]
          enum_ref = resolve_enum(definition[:enum])
          if enum_ref.is_a?(Symbol) && enums.key?(enum_ref)
            base_type = zod_type_name(enum_ref)
          elsif enum_ref.is_a?(Array)
            base_type = enum_ref.map { |v| "'#{v}'" }.join(' | ')
          end
        end

        # Apply nullable (add | null to the type)
        base_type = "#{base_type} | null" if is_nullable

        base_type
      end

      # Map type definition to TypeScript type syntax
      def map_typescript_type_definition(definition, action_name = nil)
        type = definition[:type]

        case type
        when :object
          map_typescript_object_type(definition, action_name)
        when :array
          map_typescript_array_type(definition, action_name)
        when :union
          map_typescript_union_type(definition, action_name)
        when :literal
          map_typescript_literal_type(definition)
        else
          # Primitive or custom type reference
          if types.key?(type)
            zod_type_name(type)
          else
            map_typescript_primitive(type)
          end
        end
      end

      # Map object type to TypeScript syntax (inline)
      def map_typescript_object_type(definition, action_name = nil)
        return '{}' unless definition[:shape]

        properties = definition[:shape].map do |property_name, property_def|
          key = transform_key(property_name)
          ts_type = map_typescript_field(property_def, action_name)
          "#{key}: #{ts_type}"
        end.join('; ')

        "{ #{properties} }"
      end

      # Map array type to TypeScript syntax
      def map_typescript_array_type(definition, action_name = nil)
        items_type = definition[:of]
        return 'string[]' unless items_type

        if items_type.is_a?(Symbol) && types.key?(items_type)
          element_type = zod_type_name(items_type)
        elsif items_type.is_a?(Hash)
          element_type = map_typescript_type_definition(items_type, action_name)
        else
          element_type = map_typescript_primitive(items_type)
        end

        # Use bracket notation for arrays
        # For complex types (unions, intersections), wrap in parentheses
        if element_type.include?(' | ') || element_type.include?(' & ')
          "(#{element_type})[]"
        else
          "#{element_type}[]"
        end
      end

      # Map union type to TypeScript union syntax
      def map_typescript_union_type(definition, action_name = nil)
        variants = definition[:variants].map do |variant|
          map_typescript_type_definition(variant, action_name)
        end
        variants.join(' | ')
      end

      # Map literal type to TypeScript literal syntax
      def map_typescript_literal_type(definition)
        value = definition[:value]
        case value
        when String
          "'#{value}'"
        when Integer, Float
          value.to_s
        when TrueClass, FalseClass
          value.to_s
        when NilClass
          'null'
        else
          "'#{value}'"
        end
      end

      # Map primitive type to TypeScript primitive
      def map_typescript_primitive(type)
        case type.to_sym
        when :string, :text, :uuid, :date, :datetime, :time, :binary
          'string'
        when :integer, :float, :decimal, :number
          'number'
        when :boolean
          'boolean'
        when :json
          'Record<string, any>'
        else
          'string'
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
