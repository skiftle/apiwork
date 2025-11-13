# frozen_string_literal: true

module Apiwork
  module Generation
    # Zod schema generator using API introspection
    #
    # Generates TypeScript Zod schemas from API introspection data.
    # Uses contract-based type system instead of schema introspection.
    # Targets Zod 3 API by default.
    #
    # @example Generate Zod schemas
    #   generator = Zod.new('/api/v1')
    #   schemas = generator.generate
    #   File.write('schemas.ts', schemas)
    #
    # @example Target specific Zod version
    #   generator = Zod.new('/api/v1', version: '3')
    #   schemas = generator.generate
    class Zod < Base
      generator_name :zod
      content_type 'text/plain; charset=utf-8'

      VALID_VERSIONS = ['3', '4'].freeze

      def self.file_extension
        '.ts'
      end

      def self.default_options
        { version: '4' }
      end

      def initialize(path, **options)
        super
        validate_version!
      end

      # Generate complete TypeScript document with Zod schemas
      #
      # @return [String] TypeScript document content
      def generate
        parts = []

        parts << "import { z } from 'zod';\n"

        enum_schemas = build_enum_schemas
        if enum_schemas.present?
          parts << enum_schemas
          parts << ''
        end

        type_schemas = build_type_schemas
        if type_schemas.present?
          parts << type_schemas
          parts << ''
        end

        typescript_enum_types = build_typescript_enum_types
        if typescript_enum_types.present?
          parts << typescript_enum_types
          parts << ''
        end

        typescript_types = build_typescript_types
        if typescript_types.present?
          parts << typescript_types
          parts << ''
        end

        parts.join("\n")
      end

      private

      # Map contract type to Zod type
      TYPE_MAP = {
        string: 'z.string()',
        text: 'z.string()',
        uuid: 'z.uuid()',
        integer: 'z.number().int()',
        float: 'z.number()',
        decimal: 'z.number()',
        number: 'z.number()',
        boolean: 'z.boolean()',
        date: 'z.iso.date()',
        datetime: 'z.iso.datetime()',
        time: 'z.iso.time()',
        json: 'z.record(z.string(), z.any())',
        binary: 'z.string()'
      }.freeze

      # Build enum schemas from introspect data
      def build_enum_schemas
        return '' if enums.empty?

        # Enum filter schemas are now auto-generated as union types in introspect[:types]
        # No need for manual generation here
        enums.map do |enum_name, enum_values|
          schema_name = zod_type_name(enum_name)
          values_str = enum_values.map { |v| "'#{v}'" }.join(', ')
          "export const #{schema_name}Schema: z.ZodType<#{schema_name}> = z.enum([#{values_str}]);"
        end.join("\n")
      end

      # Build TypeScript enum types from introspect data
      def build_typescript_enum_types
        return '' if enums.empty?

        # Generate TypeScript union types for enums
        # Enum filter types are now auto-generated as union types in introspect[:types]
        enums.map do |enum_name, enum_values|
          type_name = zod_type_name(enum_name)
          # Create a union of literal types
          values_str = enum_values.map { |v| "'#{v}'" }.join(' | ')
          "export type #{type_name} = #{values_str};"
        end.join("\n")
      end

      # Build schemas for all types from introspect
      def build_type_schemas
        # Sort ALL types in topological order to avoid forward references
        sorted_types = topological_sort_types(types)

        # Generate schemas for all types
        schemas = sorted_types.map do |type_name, type_shape|
          # Check if this is a union type (has :type => :union at root level)
          if type_shape.is_a?(Hash) && type_shape[:type] == :union
            build_union_schema(type_name, type_shape)
          else
            # Regular object type
            action_name = type_name.to_s.end_with?('_update_payload') ? 'update' : nil
            recursive = detect_circular_references(type_name, type_shape)
            build_object_schema(type_name, type_shape, action_name, recursive: recursive)
          end
        end

        schemas.join("\n\n")
      end

      # Sort types in topological order to avoid forward references
      # Types that don't depend on other types come first
      def topological_sort_types(all_types)
        # Build reverse dependency graph (who depends on me)
        # If A depends on B, we store B -> [A] so B comes before A
        reverse_deps = Hash.new { |h, k| h[k] = [] }

        all_types.each do |type_name, type_shape|
          # Extract type references from this type
          referenced_types = extract_type_references(type_shape, filter: all_types.keys)

          referenced_types.each do |ref|
            next if ref == type_name # Skip self-references (recursive types)

            reverse_deps[ref] << type_name
          end
        end

        # Topological sort using Kahn's algorithm
        sorted = []
        in_degree = Hash.new(0)

        # Calculate in-degrees (how many types depend on me)
        reverse_deps.each_value do |dependents|
          dependents.each { |dependent| in_degree[dependent] += 1 }
        end

        # Start with types that have no dependencies (in_degree = 0)
        queue = all_types.keys.select { |type| in_degree[type].zero? }

        while queue.any?
          current = queue.shift
          sorted << current

          # Remove edges: types that depend on current can now be processed
          reverse_deps[current].each do |dependent|
            in_degree[dependent] -= 1
            queue << dependent if in_degree[dependent].zero?
          end
        end

        # If sorted.size != all_types.size, there's a cycle
        # Keep successfully sorted types, append unsorted (circular) types at end
        # Circular types will use z.lazy() which supports forward references
        if sorted.size != all_types.size
          unsorted_types = all_types.keys - sorted
          (sorted + unsorted_types).map { |type_name| [type_name, all_types[type_name]] }
        else
          sorted.map { |type_name| [type_name, all_types[type_name]] }
        end
      end

      # Extract references to other types from a type definition
      # Unified method that handles both topological sorting and circular reference detection
      #
      # @param definition [Hash] Type definition (params hash)
      # @param filter [Symbol, Array] Filter strategy:
      #   - :custom_only - Only custom types (excludes primitives)
      #   - Array - Only types in the provided list
      # @return [Array<Symbol>] Array of referenced type names
      def extract_type_references(definition, filter: :custom_only)
        referenced_types = []

        definition.each_value do |param|
          next unless param.is_a?(Hash)

          # Direct type reference
          add_type_if_matches(referenced_types, param[:type], filter)

          # Array 'of' reference
          add_type_if_matches(referenced_types, param[:of], filter)

          # Union variant references
          if param[:variants].is_a?(Array)
            param[:variants].each do |variant|
              next unless variant.is_a?(Hash)

              add_type_if_matches(referenced_types, variant[:type], filter)
              add_type_if_matches(referenced_types, variant[:of], filter)

              # Recursively check nested shape in variants
              referenced_types.concat(extract_type_references(variant[:shape], filter: filter)) if variant[:shape].is_a?(Hash)
            end
          end

          # Recursively check nested shapes
          referenced_types.concat(extract_type_references(param[:shape], filter: filter)) if param[:shape].is_a?(Hash)
        end

        referenced_types.uniq
      end

      # Helper to add a type reference if it matches the filter criteria
      def add_type_if_matches(collection, type_ref, filter)
        return unless type_ref

        # Normalize to symbol
        type_sym = type_ref.is_a?(String) ? type_ref.to_sym : type_ref
        return unless type_sym.is_a?(Symbol)

        # Apply filter
        case filter
        when :custom_only
          collection << type_sym unless primitive_type?(type_sym)
        when Array
          collection << type_sym if filter.include?(type_sym)
        end
      end

      # Build Zod object schema from type shape
      def build_object_schema(type_name, type_shape, action_name = nil, recursive: false)
        schema_name = zod_type_name(type_name)

        properties = type_shape.sort_by { |property_name, _| property_name.to_s }.map do |property_name, property_def|
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

      # Build Zod union schema from union type shape
      def build_union_schema(type_name, type_shape)
        schema_name = zod_type_name(type_name)
        variants = type_shape[:variants]

        # Map each variant to its Zod schema representation
        variant_schemas = variants.map { |variant| map_type_definition(variant, nil) }

        # Format with line breaks for readability
        variants_str = variant_schemas.map { |v| "  #{v}" }.join(",\n")
        "export const #{schema_name}Schema: z.ZodType<#{schema_name}> = z.union([\n#{variants_str}\n]);"
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
          # Check if this is a custom type reference (in types) or enum reference
          enum_or_type_reference?(type) ? schema_reference(type) : map_primitive(type)
        end
      end

      # Map object type to Zod schema (inline)
      def map_object_type(definition, action_name = nil)
        return 'z.object({})' unless definition[:shape]

        # Check if this is a partial object (all fields optional)
        is_partial = definition[:partial] == true

        properties = definition[:shape].sort_by { |property_name, _| property_name.to_s }.map do |property_name, property_def|
          key = transform_key(property_name)
          # For partial objects, don't add .optional() modifiers - let .partial() handle it
          zod_type = if is_partial
                       map_field_definition(property_def.merge(required: true), nil)
                     else
                       map_field_definition(property_def, action_name)
                     end
          "#{key}: #{zod_type}"
        end.join(', ')

        base_object = "z.object({ #{properties} })"
        is_partial ? "#{base_object}.partial()" : base_object
      end

      # Map array type to Zod schema
      def map_array_type(definition, action_name = nil)
        items_type = definition[:of]
        return 'z.array(z.string())' unless items_type

        if items_type.is_a?(Symbol) && enum_or_type_reference?(items_type)
          "z.array(#{schema_reference(items_type)})"
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
          # Check if this is a union type
          if type_shape.is_a?(Hash) && type_shape[:type] == :union
            build_typescript_union_type(type_name, type_shape)
          else
            action_name = type_name.to_s.end_with?('_update_payload') ? 'update' : nil
            recursive = detect_circular_references(type_name, type_shape)
            build_typescript_type(type_name, type_shape, action_name, recursive: recursive)
          end
        end

        type_declarations.join("\n\n")
      end

      # Build TypeScript type declaration
      def build_typescript_type(type_name, type_shape, action_name = nil, recursive: false)
        type_name_pascal = zod_type_name(type_name)

        properties = type_shape.sort_by { |property_name, _| property_name.to_s }.map do |property_name, property_def|
          key = transform_key(property_name)
          is_update = action_name.to_s == 'update'
          is_optional = is_update || !property_def[:required]

          ts_type = map_typescript_field(property_def, action_name)
          optional_marker = is_optional ? '?' : ''
          "  #{key}#{optional_marker}: #{ts_type};"
        end.join("\n")

        # Always use interface for consistency
        "export interface #{type_name_pascal} {\n#{properties}\n}"
      end

      # Build TypeScript union type declaration
      def build_typescript_union_type(type_name, type_shape)
        type_name_pascal = zod_type_name(type_name)
        variants = type_shape[:variants]

        # Map each variant to its TypeScript type representation
        variant_types = variants.map { |variant| map_typescript_type_definition(variant, nil) }

        # Use type alias for unions (not interface)
        "export type #{type_name_pascal} = #{variant_types.join(' | ')};"
      end

      # Map field definition to TypeScript type syntax
      def map_typescript_field(definition, action_name = nil)
        return 'string' unless definition.is_a?(Hash)

        is_nullable = definition[:nullable]

        # Handle custom type or enum references
        base_type = if definition[:type].is_a?(Symbol) && enum_or_type_reference?(definition[:type])
                      typescript_reference(definition[:type])
                    else
                      map_typescript_type_definition(definition, action_name)
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

      # Detect if a type has direct circular references (references itself)
      # Used to determine if z.lazy() is needed for the Zod schema
      #
      # @param type_name [Symbol] The name of the type being checked
      # @param type_def [Hash] The type definition (params hash)
      # @return [Boolean] true if type directly references itself
      def detect_circular_references(type_name, type_def)
        referenced_types = extract_type_references(type_def, filter: :custom_only)
        referenced_types.include?(type_name)
      end

      # Check if a type is a primitive/built-in type (not a custom type reference)
      #
      # @param type [Symbol] Type name to check
      # @return [Boolean] true if type is a primitive
      def primitive_type?(type)
        %i[
          string integer boolean datetime date uuid object array
          decimal float literal union enum
        ].include?(type)
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
          # Check if this is a custom type reference (in types) or enum reference
          enum_or_type_reference?(type) ? typescript_reference(type) : map_typescript_primitive(type)
        end
      end

      # Map object type to TypeScript syntax (inline)
      def map_typescript_object_type(definition, action_name = nil)
        return '{}' unless definition[:shape]

        # Check if this is a partial object (all fields optional)
        is_partial = definition[:partial] == true

        properties = definition[:shape].sort_by { |property_name, _| property_name.to_s }.map do |property_name, property_def|
          key = transform_key(property_name)
          ts_type = map_typescript_field(property_def, action_name)
          # For partial objects, all fields are optional regardless of required flag
          is_optional = is_partial || !property_def[:required]
          optional_marker = is_optional ? '?' : ''
          "#{key}#{optional_marker}: #{ts_type}"
        end.join('; ')

        "{ #{properties} }"
      end

      # Map array type to TypeScript syntax
      def map_typescript_array_type(definition, action_name = nil)
        items_type = definition[:of]
        return 'string[]' unless items_type

        element_type = if items_type.is_a?(Symbol) && enum_or_type_reference?(items_type)
                         typescript_reference(items_type)
                       elsif items_type.is_a?(Hash)
                         map_typescript_type_definition(items_type, action_name)
                       else
                         map_typescript_primitive(items_type)
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

      # Check if a symbol is a custom type or enum reference
      def enum_or_type_reference?(symbol)
        types.key?(symbol) || enums.key?(symbol)
      end

      # Get the schema reference name for a custom type or enum
      def schema_reference(symbol)
        "#{zod_type_name(symbol)}Schema"
      end

      # Get the TypeScript type name for a custom type or enum
      def typescript_reference(symbol)
        zod_type_name(symbol)
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

      # Validate version option
      def validate_version!
        return if version.nil?

        unless VALID_VERSIONS.include?(version)
          raise ArgumentError,
                "Invalid version for zod: #{version.inspect}. " \
                "Valid versions: #{VALID_VERSIONS.join(', ')}"
        end
      end
    end
  end
end
