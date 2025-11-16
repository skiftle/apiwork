# frozen_string_literal: true

module Apiwork
  module Generator
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

      def generate
        build_all_typescript_types
      end

      private

      # Collects and generates all TypeScript types:
      # - Enums
      # - Regular types
      # - Action input/output types
      def build_all_typescript_types
        all_types = []

        # Collect enum types
        enums.each do |enum_name, enum_values|
          type_name = pascal_case_type_name(enum_name)
          values_str = enum_values.sort.map { |v| "'#{v}'" }.join(' | ')
          all_types << { name: type_name, code: "export type #{type_name} = #{values_str};" }
        end

        # Collect regular types (topologically sorted to avoid forward references)
        sorted_types = topological_sort_types(types)
        sorted_types.each do |type_name, type_shape|
          type_name_pascal = pascal_case_type_name(type_name)
          code = if type_shape.is_a?(Hash) && type_shape[:type] == :union
                   build_typescript_union_type(type_name, type_shape)
                 else
                   action_name = type_name.to_s.end_with?('_update_payload') ? 'update' : nil
                   recursive = detect_circular_references(type_name, type_shape)
                   build_typescript_type(type_name, type_shape, action_name, recursive: recursive)
                 end
          all_types << { name: type_name_pascal, code: code }
        end

        # Collect action types (input/output for each action)
        each_resource do |resource_name, resource_data, parent_path|
          each_action(resource_data) do |action_name, action_data|
            if action_data[:input]&.any?
              type_name = action_type_name(resource_name, action_name, 'Input', parent_path)
              code = build_action_input_typescript_type(resource_name, action_name, action_data[:input], parent_path)
              all_types << { name: type_name, code: code }
            end

            next unless action_data[:output]

            type_name = action_type_name(resource_name, action_name, 'Output', parent_path)
            code = build_action_output_typescript_type(resource_name, action_name, action_data[:output], parent_path)
            all_types << { name: type_name, code: code }
          end
        end

        # Sort all types alphabetically by name and return
        all_types.sort_by { |t| t[:name] }.map { |t| t[:code] }.join("\n\n")
      end

      # Sort types in topological order to avoid forward references
      def topological_sort_types(all_types)
        reverse_deps = Hash.new { |h, k| h[k] = [] }

        all_types.each do |type_name, type_shape|
          referenced_types = extract_type_references(type_shape, filter: all_types.keys)

          referenced_types.each do |ref|
            next if ref == type_name # Skip self-references (recursive types)

            reverse_deps[ref] << type_name
          end
        end

        # Topological sort using Kahn's algorithm
        sorted = []
        in_degree = Hash.new(0)

        # Calculate in-degrees
        reverse_deps.each_value do |dependents|
          dependents.each { |dependent| in_degree[dependent] += 1 }
        end

        # Start with types that have no dependencies
        queue = all_types.keys.select { |type| in_degree[type].zero? }

        while queue.any?
          current = queue.shift
          sorted << current

          # Remove edges
          reverse_deps[current].each do |dependent|
            in_degree[dependent] -= 1
            queue << dependent if in_degree[dependent].zero?
          end
        end

        if sorted.size != all_types.size
          unsorted_types = all_types.keys - sorted
          (sorted + unsorted_types).map { |type_name| [type_name, all_types[type_name]] }
        else
          sorted.map { |type_name| [type_name, all_types[type_name]] }
        end
      end

      # Extract all type references from a definition
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

      # Helper to add a type reference if it matches the filter
      def add_type_if_matches(collection, type_ref, filter)
        return unless type_ref

        type_sym = type_ref.is_a?(String) ? type_ref.to_sym : type_ref
        return unless type_sym.is_a?(Symbol)

        case filter
        when :custom_only
          collection << type_sym unless primitive_type?(type_sym)
        when Array
          collection << type_sym if filter.include?(type_sym)
        end
      end

      # Detect if a type has circular references to itself
      def detect_circular_references(type_name, type_def)
        referenced_types = extract_type_references(type_def, filter: :custom_only)
        referenced_types.include?(type_name)
      end

      # Build TypeScript interface for a type
      def build_typescript_type(type_name, type_shape, action_name = nil, recursive: false)
        type_name_pascal = pascal_case_type_name(type_name)

        properties = type_shape.sort_by { |property_name, _| property_name.to_s }.map do |property_name, property_def|
          key = transform_key(property_name)
          is_update = action_name.to_s == 'update'
          is_required = property_def[:required]

          ts_type = map_typescript_field(property_def, action_name)
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
      def build_typescript_union_type(type_name, type_shape)
        type_name_pascal = pascal_case_type_name(type_name)
        variants = type_shape[:variants]

        variant_types = variants.map { |variant| map_typescript_type_definition(variant, nil) }

        "export type #{type_name_pascal} = #{variant_types.join(' | ')};"
      end

      # Build TypeScript interface for action input
      def build_action_input_typescript_type(resource_name, action_name, input_params, parent_path = nil)
        type_name = action_type_name(resource_name, action_name, 'Input', parent_path)

        properties = input_params.sort_by { |k, _| k.to_s }.map do |param_name, param_def|
          key = transform_key(param_name)
          ts_type = map_typescript_field(param_def, action_name)
          is_required = param_def[:required]
          optional_marker = is_required ? '' : '?'
          "  #{key}#{optional_marker}: #{ts_type};"
        end.join("\n")

        "export interface #{type_name} {\n#{properties}\n}"
      end

      # Build TypeScript type alias for action output
      def build_action_output_typescript_type(resource_name, action_name, output_def, parent_path = nil)
        type_name = action_type_name(resource_name, action_name, 'Output', parent_path)

        ts_type = map_typescript_type_definition(output_def, action_name)

        "export type #{type_name} = #{ts_type};"
      end

      # Generate action type name (e.g., PostCreateInput, PostCommentUpdateOutput)
      def action_type_name(resource_name, action_name, suffix, parent_path = nil)
        parent_names = extract_parent_resource_names(parent_path)
        parts = parent_names + [
          resource_name.to_s,
          action_name.to_s,
          suffix
        ]
        pascal_case_type_name(parts.join('_'))
      end

      # Extract parent resource names from path (e.g., /posts/:post_id/comments -> ['posts'])
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

      # Map a field definition to TypeScript type
      def map_typescript_field(definition, action_name = nil)
        return 'string' unless definition.is_a?(Hash)

        is_nullable = definition[:nullable]

        base_type = if definition[:type].is_a?(Symbol) && enum_or_type_reference?(definition[:type])
                      typescript_reference(definition[:type])
                    else
                      map_typescript_type_definition(definition, action_name)
                    end

        if definition[:enum]
          enum_ref = resolve_enum(definition[:enum])
          if enum_ref.is_a?(Symbol) && enums.key?(enum_ref)
            base_type = pascal_case_type_name(enum_ref)
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
      def map_typescript_type_definition(definition, action_name = nil)
        return 'never' unless definition.is_a?(Hash)

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
        when nil
          'never'
        else
          enum_or_type_reference?(type) ? typescript_reference(type) : map_typescript_primitive(type)
        end
      end

      # Map object type to TypeScript inline object type
      def map_typescript_object_type(definition, action_name = nil)
        return 'object' unless definition[:shape]

        is_partial = definition[:partial]

        properties = definition[:shape].sort_by { |property_name, _| property_name.to_s }.map do |property_name, property_def|
          key = transform_key(property_name)
          ts_type = map_typescript_field(property_def, action_name)
          is_required = property_def[:required]
          optional_marker = is_partial || !is_required ? '?' : ''
          "#{key}#{optional_marker}: #{ts_type}"
        end.join('; ')

        "{ #{properties} }"
      end

      # Map array type to TypeScript array type
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
        if element_type.include?(' | ') || element_type.include?(' & ')
          "(#{element_type})[]"
        else
          "#{element_type}[]"
        end
      end

      # Map union type to TypeScript union
      def map_typescript_union_type(definition, action_name = nil)
        variants = definition[:variants].map do |variant|
          map_typescript_type_definition(variant, action_name)
        end
        variants.sort.join(' | ')
      end

      # Map literal value to TypeScript literal type
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

      # Check if symbol is a custom type or enum reference
      def enum_or_type_reference?(symbol)
        types.key?(symbol) || enums.key?(symbol)
      end

      # Check if type is a primitive
      def primitive_type?(type)
        %i[
          string integer boolean datetime date uuid object array
          decimal float literal union enum text binary json number time
        ].include?(type)
      end

      # Convert symbol to TypeScript type reference
      def typescript_reference(symbol)
        pascal_case_type_name(symbol)
      end

      # Convert name to PascalCase for TypeScript
      def pascal_case_type_name(name)
        name.to_s.camelize(:upper)
      end

      # Resolve enum reference (identity function for now)
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
