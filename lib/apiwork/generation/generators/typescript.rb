# frozen_string_literal: true

module Apiwork
  module Generation
    module Generators
      # TypeScript type generator using API introspection
      #
      # Generates pure TypeScript type definitions from API introspection data.
      # Types are sorted alphabetically for consistency and readability.
      # Targets TypeScript 5 by default.
      #
      # Available at: GET /api/v1/.spec/typescript
      #
      # @example Generate TypeScript types
      #   generator = Typescript.new('/api/v1')
      #   types = generator.generate
      #   File.write('types.ts', types)
      #
      # @example Target specific TypeScript version
      #   generator = Typescript.new('/api/v1', version: '5')
      #   types = generator.generate
      class Typescript < Base
        generator_name :typescript
        content_type 'text/plain; charset=utf-8'

        VALID_VERSIONS = %w[4 5].freeze

        def self.file_extension
          '.ts'
        end

        def self.default_options
          { version: '5' }
        end

        def initialize(path, **options)
          super
          validate_version!
        end

        # Generate complete TypeScript document with type definitions
        #
        # @return [String] TypeScript document content
        def generate
          all_declarations = []

          # Combine enums and types, sort alphabetically
          combined = {}

          # Add all enums
          enums.each do |enum_name, enum_values|
            combined[enum_name] = { kind: :enum, data: enum_values }
          end

          # Add all types
          types.each do |type_name, type_shape|
            combined[type_name] = { kind: :type, data: type_shape }
          end

          # Sort alphabetically and generate
          combined.sort_by { |name, _| name.to_s }.each do |name, info|
            all_declarations << if info[:kind] == :enum
                                  build_single_typescript_enum(name, info[:data])
                                else
                                  build_single_typescript_type(name, info[:data])
                                end
          end

          all_declarations.join("\n\n")
        end

        private

        # Build a single TypeScript enum type
        def build_single_typescript_enum(enum_name, enum_values)
          type_name = pascal_case_type_name(enum_name)
          # Create a union of literal types
          values_str = enum_values.map { |v| "'#{v}'" }.join(' | ')
          "export type #{type_name} = #{values_str};"
        end

        # Build a single TypeScript type declaration
        def build_single_typescript_type(type_name, type_shape)
          # Check if this is a union type
          if type_shape.is_a?(Hash) && type_shape[:type] == :union
            build_typescript_union_type(type_name, type_shape)
          else
            build_typescript_interface(type_name, type_shape)
          end
        end

        # Build TypeScript type declaration (interface)
        def build_typescript_interface(type_name, type_shape)
          type_name_pascal = pascal_case_type_name(type_name)

          # Sort properties alphabetically
          properties = type_shape.sort_by { |property_name, _| property_name.to_s }.map do |property_name, property_def|
            key = transform_key(property_name)
            ts_type = map_typescript_field(property_def)
            is_optional = !property_def[:required]
            optional_marker = is_optional ? '?' : ''
            "  #{key}#{optional_marker}: #{ts_type};"
          end.join("\n")

          # Always use interface for consistency
          "export interface #{type_name_pascal} {\n#{properties}\n}"
        end

        # Build TypeScript union type declaration
        def build_typescript_union_type(type_name, type_shape)
          type_name_pascal = pascal_case_type_name(type_name)
          variants = type_shape[:variants]

          # Map each variant to its TypeScript type representation
          variant_types = variants.map { |variant| map_typescript_type_definition(variant) }

          # Use type alias for unions (not interface)
          "export type #{type_name_pascal} = #{variant_types.join(' | ')};"
        end

        # Map field definition to TypeScript type syntax
        def map_typescript_field(definition)
          return 'string' unless definition.is_a?(Hash)

          is_nullable = definition[:nullable]

          # Handle custom type or enum references
          base_type = if definition[:type].is_a?(Symbol) && enum_or_type_reference?(definition[:type])
                        typescript_reference(definition[:type])
                      else
                        map_typescript_type_definition(definition)
                      end

          # Handle enum
          if definition[:enum]
            enum_ref = resolve_enum(definition[:enum])
            if enum_ref.is_a?(Symbol) && enums.key?(enum_ref)
              base_type = pascal_case_type_name(enum_ref)
            elsif definition[:enum].is_a?(Array)
              values_str = definition[:enum].map { |v| "'#{v}'" }.join(' | ')
              base_type = values_str
            end
          end

          # Apply nullable modifier
          if is_nullable
            "#{base_type} | null"
          else
            base_type
          end
        end

        # Map type definition to TypeScript syntax
        def map_typescript_type_definition(definition)
          return 'string' unless definition.is_a?(Hash)

          type = definition[:type]

          case type
          when :object
            map_typescript_object_type(definition)
          when :array
            map_typescript_array_type(definition)
          when :union
            map_typescript_union_type(definition)
          when :literal
            map_typescript_literal_type(definition)
          else
            # Check if this is a custom type reference (in types) or enum reference
            enum_or_type_reference?(type) ? typescript_reference(type) : map_typescript_primitive(type)
          end
        end

        # Map object type to TypeScript syntax (inline)
        def map_typescript_object_type(definition)
          return '{}' unless definition[:shape]

          # Check if this is a partial object (all fields optional)
          is_partial = definition[:partial] == true

          # Sort properties alphabetically
          properties = definition[:shape].sort_by { |property_name, _| property_name.to_s }.map do |property_name, property_def|
            key = transform_key(property_name)
            ts_type = map_typescript_field(property_def)
            # For partial objects, all fields are optional regardless of required flag
            is_optional = is_partial || !property_def[:required]
            optional_marker = is_optional ? '?' : ''
            "#{key}#{optional_marker}: #{ts_type}"
          end.join('; ')

          "{ #{properties} }"
        end

        # Map array type to TypeScript syntax
        def map_typescript_array_type(definition)
          items_type = definition[:of]
          return 'string[]' unless items_type

          element_type = if items_type.is_a?(Symbol) && enum_or_type_reference?(items_type)
                           typescript_reference(items_type)
                         elsif items_type.is_a?(Hash)
                           map_typescript_type_definition(items_type)
                         else
                           map_typescript_primitive(items_type)
                         end

          # Use bracket notation for arrays
          # For complex types (unions, intersections), wrap in parentheses
          if element_type.include?('|') || element_type.include?('&')
            "(#{element_type})[]"
          else
            "#{element_type}[]"
          end
        end

        # Map union type to TypeScript syntax (inline union for fields)
        def map_typescript_union_type(definition)
          variants = definition[:variants]
          return 'string' unless variants

          variant_types = variants.map { |variant| map_typescript_type_definition(variant) }
          variant_types.join(' | ')
        end

        # Map literal type to TypeScript syntax
        def map_typescript_literal_type(definition)
          value = definition[:value]

          case value
          when String
            "'#{value}'"
          when Integer, Float
            value.to_s
          when TrueClass
            'true'
          when FalseClass
            'false'
          when NilClass
            'null'
          else
            'unknown'
          end
        end

        # Map primitive type to TypeScript type
        def map_typescript_primitive(type)
          case type.to_sym
          when :string, :text, :binary then 'string'
          when :integer then 'number'
          when :float, :decimal then 'number'
          when :boolean then 'boolean'
          when :date then 'string'
          when :datetime then 'string'
          when :time then 'string'
          when :json then 'Record<string, any>'
          else 'string'
          end
        end

        # Check if a symbol is a custom type or enum reference
        def enum_or_type_reference?(symbol)
          types.key?(symbol) || enums.key?(symbol)
        end

        # Check if a type is a primitive type
        def primitive_type?(type)
          %i[string integer float decimal boolean date datetime time text binary json].include?(type.to_sym)
        end

        # Get the TypeScript type name for a custom type or enum
        def typescript_reference(symbol)
          pascal_case_type_name(symbol)
        end

        # Convert snake_case symbol to PascalCase type name
        def pascal_case_type_name(name)
          Transform::Case.string(name.to_s, :camelize_upper)
        end

        # Resolve enum reference
        def resolve_enum(enum_ref)
          enum_ref
        end

        # Validate version option
        def validate_version!
          return if version.nil?

          return if VALID_VERSIONS.include?(version)

          raise ArgumentError,
                "Invalid version for typescript: #{version.inspect}. " \
                "Valid versions: #{VALID_VERSIONS.join(', ')}"
        end
      end
    end
  end
end
