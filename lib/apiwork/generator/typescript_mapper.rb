# frozen_string_literal: true

module Apiwork
  module Generator
    # Pure TypeScript type mapping service
    # Converts introspection data to TypeScript type strings
    # No side effects, no file I/O, just pure string generation
    class TypescriptMapper
      attr_reader :introspection, :key_transform_strategy

      def initialize(introspection:, key_transform: :keep)
        @introspection = introspection
        @key_transform_strategy = key_transform
      end

      # Build complete TypeScript interface from type definition
      def build_interface(type_name, type_shape, action_name = nil, recursive: false)
        type_name_pascal = pascal_case(type_name)

        properties = type_shape.sort_by { |property_name, _| property_name.to_s }.map do |property_name, property_def|
          key = transform_key(property_name)
          is_update = action_name.to_s == 'update'
          is_required = property_def[:required]

          ts_type = map_field(property_def, action_name)
          optional_marker = is_update || !is_required ? '?' : ''
          "  #{key}#{optional_marker}: #{ts_type};"
        end.join("\n")

        # Empty objects become type aliases to object
        if properties.empty?
          "export type #{type_name_pascal} = object;"
        else
          "export interface #{type_name_pascal} {\n#{properties}\n}"
        end
      end

      # Build TypeScript union type
      def build_union_type(type_name, type_shape)
        type_name_pascal = pascal_case(type_name)
        variants = type_shape[:variants]

        variant_types = variants.map { |variant| map_type_definition(variant, nil) }

        "export type #{type_name_pascal} = #{variant_types.join(' | ')};"
      end

      # Build TypeScript interface for action input
      def build_action_input_type(resource_name, action_name, input_params, parent_path = nil)
        type_name = action_type_name(resource_name, action_name, 'Input', parent_path)

        properties = input_params.sort_by { |k, _| k.to_s }.map do |param_name, param_definition|
          key = transform_key(param_name)
          ts_type = map_field(param_definition, action_name)
          is_required = param_definition[:required]
          optional_marker = is_required ? '' : '?'
          "  #{key}#{optional_marker}: #{ts_type};"
        end.join("\n")

        "export interface #{type_name} {\n#{properties}\n}"
      end

      # Build TypeScript type alias for action output
      def build_action_output_type(resource_name, action_name, output_def, parent_path = nil)
        type_name = action_type_name(resource_name, action_name, 'Output', parent_path)
        ts_type = map_type_definition(output_def, action_name)
        "export type #{type_name} = #{ts_type};"
      end

      # Generate action type name (e.g., PostCreateInput)
      def action_type_name(resource_name, action_name, suffix, parent_path = nil)
        parent_names = extract_parent_resource_names(parent_path)
        parts = parent_names + [resource_name.to_s, action_name.to_s, suffix]
        pascal_case(parts.join('_'))
      end

      # Map a field definition to TypeScript type
      def map_field(definition, action_name = nil)
        return 'string' unless definition.is_a?(Hash)

        is_nullable = definition[:nullable]

        base_type = if definition[:type].is_a?(Symbol) && enum_or_type_reference?(definition[:type])
                      type_reference(definition[:type])
                    else
                      map_type_definition(definition, action_name)
                    end

        if definition[:enum]
          enum_ref = resolve_enum(definition[:enum])
          if enum_ref.is_a?(Symbol) && enums.key?(enum_ref)
            base_type = pascal_case(enum_ref)
          elsif enum_ref.is_a?(Array)
            base_type = enum_ref.sort.map { |v| "'#{v}'" }.join(' | ')
          end
        end

        if is_nullable
          members = [base_type, 'null'].sort
          base_type = members.join(' | ')
        end

        base_type
      end

      # Map a type definition to TypeScript type
      def map_type_definition(definition, action_name = nil)
        return 'never' unless definition.is_a?(Hash)

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
        when nil
          'never'
        else
          enum_or_type_reference?(type) ? type_reference(type) : map_primitive(type)
        end
      end

      # Map object type to TypeScript inline object type
      def map_object_type(definition, action_name = nil)
        return 'object' unless definition[:shape]

        is_partial = definition[:partial]

        properties = definition[:shape].sort_by { |property_name, _| property_name.to_s }.map do |property_name, property_def|
          key = transform_key(property_name)
          ts_type = map_field(property_def, action_name)
          is_required = property_def[:required]
          optional_marker = is_partial || !is_required ? '?' : ''
          "#{key}#{optional_marker}: #{ts_type}"
        end.join('; ')

        "{ #{properties} }"
      end

      # Map array type to TypeScript array type
      def map_array_type(definition, action_name = nil)
        items_type = definition[:of]
        return 'string[]' unless items_type

        element_type = if items_type.is_a?(Symbol) && enum_or_type_reference?(items_type)
                         type_reference(items_type)
                       elsif items_type.is_a?(Hash)
                         map_type_definition(items_type, action_name)
                       else
                         map_primitive(items_type)
                       end

        # Use bracket notation for arrays
        if element_type.include?(' | ') || element_type.include?(' & ')
          "(#{element_type})[]"
        else
          "#{element_type}[]"
        end
      end

      # Map union type to TypeScript union
      def map_union_type(definition, action_name = nil)
        variants = definition[:variants].map do |variant|
          map_type_definition(variant, action_name)
        end
        variants.sort.join(' | ')
      end

      # Map literal value to TypeScript literal type
      def map_literal_type(definition)
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
      def map_primitive(type)
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

      # Convert symbol to TypeScript type reference
      def type_reference(symbol)
        pascal_case(symbol)
      end

      # Convert name to PascalCase for TypeScript
      def pascal_case(name)
        name.to_s.camelize(:upper)
      end

      private

      def types
        introspection[:types] || {}
      end

      def enums
        introspection[:enums] || {}
      end

      # Check if symbol is a custom type or enum reference
      def enum_or_type_reference?(symbol)
        types.key?(symbol) || enums.key?(symbol)
      end

      # Resolve enum reference (identity function for now)
      def resolve_enum(enum_ref)
        enum_ref
      end

      # Extract parent resource names from path
      def extract_parent_resource_names(parent_path)
        return [] unless parent_path

        parent_names = []
        segments = parent_path.to_s.split('/')

        segments.each do |segment|
          next if segment.match?(/:/) # Skip ID parameters like :post_id

          parent_names << segment
        end

        parent_names
      end

      # Transform key according to strategy
      def transform_key(key)
        key_str = key.to_s

        # Preserve leading underscores (e.g., _and, _or, _not)
        leading_underscore = key_str.start_with?('_')
        base = leading_underscore ? key_str[1..] : key_str

        transformed = case key_transform_strategy
                      when :camel
                        base.camelize(:lower)
                      when :pascal
                        base.camelize(:upper)
                      else
                        base
                      end

        leading_underscore ? "_#{transformed}" : transformed
      end
    end
  end
end
