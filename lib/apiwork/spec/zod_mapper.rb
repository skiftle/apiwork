# frozen_string_literal: true

module Apiwork
  module Spec
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
        binary: 'z.string()',
        unknown: 'z.unknown()'
      }.freeze

      attr_reader :introspection,
                  :key_format

      def initialize(introspection:, key_format: :keep)
        @introspection = introspection
        @key_format = key_format
      end

      def build_object_schema(type_name, type_shape, action_name: nil, recursive: false)
        schema_name = pascal_case(type_name)

        fields = type_shape[:shape] || {}

        properties = fields.sort_by { |property_name, _| property_name.to_s }.map do |property_name, property_definition|
          key = transform_key(property_name)
          zod_type = map_field_definition(property_definition, action_name: action_name)
          "  #{key}: #{zod_type}"
        end.join(",\n")

        type_annotation = recursive ? ": z.ZodType<#{schema_name}>" : ''

        if recursive
          "export const #{schema_name}Schema#{type_annotation} = z.lazy(() => z.object({\n#{properties}\n}));"
        else
          "export const #{schema_name}Schema#{type_annotation} = z.object({\n#{properties}\n});"
        end
      end

      def build_union_schema(type_name, type_shape)
        schema_name = pascal_case(type_name)
        variants = type_shape[:variants]

        variant_schemas = variants.map { |variant| map_type_definition(variant, action_name: nil) }
        union_body = variant_schemas.map { |v| "  #{v}" }.join(",\n")

        if type_shape[:discriminator]
          discriminator_key = transform_key(type_shape[:discriminator])
          "export const #{schema_name}Schema = z.discriminatedUnion('#{discriminator_key}', [\n#{union_body}\n]);"
        else
          "export const #{schema_name}Schema = z.union([\n#{union_body}\n]);"
        end
      end

      def build_action_request_query_schema(resource_name, action_name, query_params, parent_path: nil)
        schema_name = action_schema_name(resource_name, action_name, 'RequestQuery', parent_path: parent_path)

        properties = query_params.sort_by { |k, _| k.to_s }.map do |param_name, param_definition|
          key = transform_key(param_name)
          zod_type = map_field_definition(param_definition, action_name: nil)
          "  #{key}: #{zod_type}"
        end.join(",\n")

        "export const #{schema_name}Schema = z.object({\n#{properties}\n});"
      end

      def build_action_request_body_schema(resource_name, action_name, body_params, parent_path: nil)
        schema_name = action_schema_name(resource_name, action_name, 'RequestBody', parent_path: parent_path)

        properties = body_params.sort_by { |k, _| k.to_s }.map do |param_name, param_definition|
          key = transform_key(param_name)
          zod_type = map_field_definition(param_definition, action_name: nil)
          "  #{key}: #{zod_type}"
        end.join(",\n")

        "export const #{schema_name}Schema = z.object({\n#{properties}\n});"
      end

      def build_action_request_schema(resource_name, action_name, request_data, parent_path: nil)
        schema_name = action_schema_name(resource_name, action_name, 'Request', parent_path: parent_path)

        nested_properties = []

        if request_data[:query]&.any?
          query_schema_name = action_schema_name(resource_name, action_name, 'RequestQuery', parent_path: parent_path)
          nested_properties << "  query: #{query_schema_name}Schema"
        end

        if request_data[:body]&.any?
          body_schema_name = action_schema_name(resource_name, action_name, 'RequestBody', parent_path: parent_path)
          nested_properties << "  body: #{body_schema_name}Schema"
        end

        "export const #{schema_name}Schema = z.object({\n#{nested_properties.join(",\n")}\n});"
      end

      def build_action_response_body_schema(resource_name, action_name, response_body_definition, parent_path: nil)
        schema_name = action_schema_name(resource_name, action_name, 'ResponseBody', parent_path: parent_path)

        zod_schema = map_type_definition(response_body_definition, action_name: nil)

        "export const #{schema_name}Schema = #{zod_schema};"
      end

      def build_action_response_schema(resource_name, action_name, response_data, parent_path: nil)
        schema_name = action_schema_name(resource_name, action_name, 'Response', parent_path: parent_path)
        body_schema_name = action_schema_name(resource_name, action_name, 'ResponseBody', parent_path: parent_path)

        "export const #{schema_name}Schema = z.object({\n  body: #{body_schema_name}Schema\n});"
      end

      def action_schema_name(resource_name, action_name, suffix, parent_path: nil)
        parent_names = extract_parent_resource_names(parent_path)
        base_parts = parent_names + [resource_name.to_s, action_name.to_s]
        base_name = pascal_case(base_parts.join('_'))
        suffix_pascal = suffix.split(/(?=[A-Z])/).map(&:capitalize).join
        "#{base_name}#{suffix_pascal}"
      end

      def map_field_definition(definition, action_name: nil)
        return 'z.string()' unless definition.is_a?(Hash)

        if definition[:type].is_a?(Symbol) && (types.key?(definition[:type]) || enums.key?(definition[:type]))
          schema_name = pascal_case(definition[:type])
          type = "#{schema_name}Schema"
          return apply_modifiers(type, definition, action_name)
        end

        type = map_type_definition(definition, action_name: action_name)
        type = resolve_enum_schema(definition) || type

        apply_modifiers(type, definition, action_name)
      end

      def map_type_definition(definition, action_name: nil)
        return 'z.never()' unless definition.is_a?(Hash)

        type = definition[:type]

        case type
        when :object
          map_object_type(definition, action_name: action_name)
        when :array
          map_array_type(definition, action_name: action_name)
        when :union
          map_union_type(definition, action_name: action_name)
        when :literal
          map_literal_type(definition)
        when nil
          'z.never()'
        else
          result = enum_or_type_reference?(type) ? schema_reference(type) : map_primitive(definition)
          resolve_enum_schema(definition) || result
        end
      end

      def map_object_type(definition, action_name: nil)
        return 'z.object({})' unless definition[:shape]

        partial = definition[:partial]

        properties = definition[:shape].sort_by { |property_name, _| property_name.to_s }.map do |property_name, property_definition|
          key = transform_key(property_name)
          zod_type = if partial
                       map_field_definition(property_definition.merge(optional: false), action_name: nil)
                     else
                       map_field_definition(property_definition, action_name: action_name)
                     end
          "#{key}: #{zod_type}"
        end.join(', ')

        base_object = "z.object({ #{properties} })"
        partial ? "#{base_object}.partial()" : base_object
      end

      def map_array_type(definition, action_name: nil)
        items_type = definition[:of]
        return 'z.array(z.string())' unless items_type

        if items_type.is_a?(Symbol) && enum_or_type_reference?(items_type)
          "z.array(#{schema_reference(items_type)})"
        elsif items_type.is_a?(Hash)
          items_schema = map_type_definition(items_type, action_name: action_name)
          "z.array(#{items_schema})"
        else
          primitive = map_primitive({ type: items_type })
          "z.array(#{primitive})"
        end
      end

      def map_union_type(definition, action_name: nil)
        if definition[:discriminator]
          map_discriminated_union(definition, action_name: action_name)
        else
          variants = definition[:variants].map { |variant| map_type_definition(variant, action_name: action_name) }
          "z.union([#{variants.join(', ')}])"
        end
      end

      def map_discriminated_union(definition, action_name: nil)
        discriminator_field = transform_key(definition[:discriminator])
        variants = definition[:variants]

        variant_schemas = variants.map { |variant| map_type_definition(variant, action_name: action_name) }

        "z.discriminatedUnion('#{discriminator_field}', [#{variant_schemas.join(', ')}])"
      end

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

      def map_primitive(definition)
        type = definition[:type]
        format = definition[:format]&.to_sym

        base_type = if format
                      map_format_to_zod(format)
                    else
                      TYPE_MAP[type.to_sym] || 'z.unknown()'
                    end

        if numeric_type?(type)
          base_type += ".min(#{definition[:min]})" if definition[:min]
          base_type += ".max(#{definition[:max]})" if definition[:max]
        end

        base_type
      end

      def map_format_to_zod(format)
        case format
        when :email then 'z.email()'
        when :uuid then 'z.uuid()'
        when :uri, :url then 'z.url()'
        when :ipv4 then 'z.ipv4()'
        when :ipv6 then 'z.ipv6()'
        when :date then 'z.iso.date()'
        when :date_time then 'z.iso.datetime()'
        when :password, :hostname then 'z.string()'
        when :int32, :int64 then 'z.number().int()'
        when :float, :double then 'z.number()'
        else 'z.string()'
        end
      end

      def schema_reference(symbol)
        "#{pascal_case(symbol)}Schema"
      end

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

      def enum_or_type_reference?(symbol)
        types.key?(symbol) || enums.key?(symbol)
      end

      def resolve_enum_schema(definition)
        return nil unless definition[:enum]

        enum_reference = definition[:enum]
        if enum_reference.is_a?(Symbol) && enums.key?(enum_reference)
          "#{pascal_case(enum_reference)}Schema"
        elsif enum_reference.is_a?(Array)
          enum_literal = enum_reference.map { |v| "'#{v}'" }.join(', ')
          "z.enum([#{enum_literal}])"
        end
      end

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

      def apply_modifiers(type, definition, action_name)
        update = action_name.to_s == 'update'

        type += '.nullable()' if definition[:nullable]

        discriminator = definition[:type] == :literal && !definition[:optional]

        if update && !discriminator
          type += '.optional()' unless type.include?('.optional()')
        elsif definition[:optional]
          type += '.optional()'
        end

        type
      end

      def numeric_type?(type)
        [:integer, :float, :decimal, :number].include?(type&.to_sym)
      end

      def transform_key(key)
        key = key.to_s

        leading_underscore = key.start_with?('_')
        base = leading_underscore ? key[1..] : key

        transformed = case key_format
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
