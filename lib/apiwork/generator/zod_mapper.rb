# frozen_string_literal: true

module Apiwork
  module Generator
    # Pure Zod schema mapping service
    # Converts introspection data to Zod schema strings
    # No side effects, no file I/O, just pure string generation
    class ZodMapper
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

      attr_reader :introspection, :key_transform_strategy

      def initialize(introspection:, key_transform: :keep)
        @introspection = introspection
        @key_transform_strategy = key_transform
      end

      # Build Zod object schema
      def build_object_schema(type_name, type_shape, action_name = nil, recursive: false)
        schema_name = pascal_case(type_name)

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

      # Build Zod union schema
      def build_union_schema(type_name, type_shape)
        schema_name = pascal_case(type_name)
        variants = type_shape[:variants]

        variant_schemas = variants.map { |variant| map_type_definition(variant, nil) }

        # Use discriminatedUnion if discriminator is present
        if type_shape[:discriminator]
          discriminator_key = transform_key(type_shape[:discriminator])
          # Format with line breaks for readability
          variants_str = variant_schemas.map { |v| "  #{v}" }.join(",\n")
          "export const #{schema_name}Schema: z.ZodType<#{schema_name}> = z.discriminatedUnion('#{discriminator_key}', [\n#{variants_str}\n]);"
        else
          # Format with line breaks for readability
          variants_str = variant_schemas.map { |v| "  #{v}" }.join(",\n")
          "export const #{schema_name}Schema: z.ZodType<#{schema_name}> = z.union([\n#{variants_str}\n]);"
        end
      end

      # Build Zod schema for action input
      def build_action_input_schema(resource_name, action_name, input_params, parent_path = nil)
        schema_name = action_schema_name(resource_name, action_name, 'Input', parent_path)

        # Build Zod object schema
        # Don't pass action_name - input fields should follow their own required flags
        properties = input_params.sort_by { |k, _| k.to_s }.map do |param_name, param_def|
          key = transform_key(param_name)
          zod_type = map_field_definition(param_def, nil)
          "  #{key}: #{zod_type}"
        end.join(",\n")

        "export const #{schema_name}Schema: z.ZodType<#{schema_name}> = z.object({\n#{properties}\n});"
      end

      # Build Zod schema for action output
      def build_action_output_schema(resource_name, action_name, output_def, parent_path = nil)
        schema_name = action_schema_name(resource_name, action_name, 'Output', parent_path)

        # Map the output definition (handles unions, objects, etc.)
        # Don't pass action_name - output fields should follow their own required flags
        zod_schema = map_type_definition(output_def, nil)

        "export const #{schema_name}Schema: z.ZodType<#{schema_name}> = #{zod_schema};"
      end

      # Generate action schema name (e.g., PostCreateInput)
      def action_schema_name(resource_name, action_name, suffix, parent_path = nil)
        parent_names = extract_parent_resource_names(parent_path)
        parts = parent_names + [resource_name.to_s, action_name.to_s, suffix]
        pascal_case(parts.join('_'))
      end

      # Map a field definition to Zod schema
      def map_field_definition(definition, action_name = nil)
        return 'z.string()' unless definition.is_a?(Hash)

        if definition[:type].is_a?(Symbol) && types.key?(definition[:type])
          schema_name = pascal_case(definition[:type])
          type = "#{schema_name}Schema"
          return apply_modifiers(type, definition, action_name)
        end

        type = map_type_definition(definition, action_name)

        if definition[:enum]
          enum_ref = resolve_enum(definition[:enum])
          if enum_ref.is_a?(Symbol) && enums.key?(enum_ref)
            enum_name = pascal_case(enum_ref)
            type = "#{enum_name}Schema"
          elsif enum_ref.is_a?(Array)
            values_str = enum_ref.map { |v| "'#{v}'" }.join(', ')
            type = "z.enum([#{values_str}])"
          end
        end

        apply_modifiers(type, definition, action_name)
      end

      # Map a type definition to Zod schema
      def map_type_definition(definition, action_name = nil)
        return 'z.never()' unless definition.is_a?(Hash)

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
          'z.never()'
        else
          enum_or_type_reference?(type) ? schema_reference(type) : map_primitive(definition)
        end
      end

      # Map object type to Zod inline object schema
      def map_object_type(definition, action_name = nil)
        return 'z.object({})' unless definition[:shape]

        is_partial = definition[:partial]

        properties = definition[:shape].sort_by { |property_name, _| property_name.to_s }.map do |property_name, property_def|
          key = transform_key(property_name)
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

      # Map array type to Zod array schema
      def map_array_type(definition, action_name = nil)
        items_type = definition[:of]
        return 'z.array(z.string())' unless items_type

        if items_type.is_a?(Symbol) && enum_or_type_reference?(items_type)
          "z.array(#{schema_reference(items_type)})"
        elsif items_type.is_a?(Hash)
          items_schema = map_type_definition(items_type, action_name)
          "z.array(#{items_schema})"
        else
          # items_type is a primitive type symbol - construct minimal definition
          primitive = map_primitive({ type: items_type })
          "z.array(#{primitive})"
        end
      end

      # Map union type to Zod union or discriminated union
      def map_union_type(definition, action_name = nil)
        if definition[:discriminator]
          map_discriminated_union(definition, action_name)
        else
          variants = definition[:variants].map { |variant| map_type_definition(variant, action_name) }
          "z.union([#{variants.join(', ')}])"
        end
      end

      # Map discriminated union to Zod discriminated union
      def map_discriminated_union(definition, action_name = nil)
        discriminator_field = transform_key(definition[:discriminator])
        variants = definition[:variants]

        variant_schemas = variants.map { |variant| map_type_definition(variant, action_name) }

        "z.discriminatedUnion('#{discriminator_field}', [#{variant_schemas.join(', ')}])"
      end

      # Map literal value to Zod literal schema
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

      # Map primitive type to Zod primitive schema
      def map_primitive(definition)
        type = definition[:type]
        base_type = TYPE_MAP[type.to_sym] || 'z.string()'

        # Add min/max constraints for numeric types
        if numeric_type?(type)
          base_type += ".min(#{definition[:min]})" if definition[:min]
          base_type += ".max(#{definition[:max]})" if definition[:max]
        end

        base_type
      end

      # Convert symbol to Zod schema reference
      def schema_reference(symbol)
        "#{pascal_case(symbol)}Schema"
      end

      # Convert name to PascalCase for Zod schemas
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

      # Apply Zod modifiers (nullable, optional) to a schema
      def apply_modifiers(type, definition, action_name)
        is_update = action_name.to_s == 'update'

        type += '.nullable()' if definition[:nullable]

        if is_update
          # Update actions: all fields optional
          type += '.optional()' unless type.include?('.optional()')
        elsif !definition[:required]
          # Regular fields: optional if not required
          type += '.optional()'
        end

        type
      end

      # Check if a type is numeric
      def numeric_type?(type)
        [:integer, :float, :decimal, :number].include?(type&.to_sym)
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
