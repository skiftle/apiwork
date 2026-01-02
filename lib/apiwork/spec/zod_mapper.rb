# frozen_string_literal: true

module Apiwork
  module Spec
    class ZodMapper
      TYPE_MAP = {
        binary: 'z.string()',
        boolean: 'z.boolean()',
        date: 'z.iso.date()',
        datetime: 'z.iso.datetime()',
        decimal: 'z.number()',
        float: 'z.number()',
        integer: 'z.number().int()',
        json: 'z.record(z.string(), z.any())',
        string: 'z.string()',
        time: 'z.iso.time()',
        unknown: 'z.unknown()',
        uuid: 'z.uuid()',
      }.freeze

      attr_reader :data,
                  :key_format

      def initialize(data:, key_format: :keep)
        @data = data
        @key_format = key_format
      end

      def build_object_schema(type_name, type, action_name: nil, recursive: false)
        schema_name = pascal_case(type_name)

        properties = type.shape.sort_by { |name, _| name.to_s }.map do |name, param|
          key = transform_key(name)
          zod_type = map_field_definition(param, action_name:)
          "  #{key}: #{zod_type}"
        end.join(",\n")

        type_annotation = recursive ? ": z.ZodType<#{schema_name}>" : ''

        if recursive
          "export const #{schema_name}Schema#{type_annotation} = z.lazy(() => z.object({\n#{properties}\n}));"
        else
          "export const #{schema_name}Schema#{type_annotation} = z.object({\n#{properties}\n});"
        end
      end

      def build_union_schema(type_name, type)
        schema_name = pascal_case(type_name)

        variant_schemas = type.variants.map { |variant| map_type_definition(variant, action_name: nil) }
        union_body = variant_schemas.map { |v| "  #{v}" }.join(",\n")

        if type.discriminator
          discriminator_key = transform_key(type.discriminator)
          "export const #{schema_name}Schema = z.discriminatedUnion('#{discriminator_key}', [\n#{union_body}\n]);"
        else
          "export const #{schema_name}Schema = z.union([\n#{union_body}\n]);"
        end
      end

      def build_action_request_query_schema(resource_name, action_name, query_params, parent_path: nil)
        schema_name = action_schema_name(resource_name, action_name, 'RequestQuery', parent_path:)

        properties = query_params.sort_by { |k, _| k.to_s }.map do |param_name, param_definition|
          key = transform_key(param_name)
          zod_type = map_field_definition(param_definition, action_name: nil)
          "  #{key}: #{zod_type}"
        end.join(",\n")

        "export const #{schema_name}Schema = z.object({\n#{properties}\n});"
      end

      def build_action_request_body_schema(resource_name, action_name, body_params, parent_path: nil)
        schema_name = action_schema_name(resource_name, action_name, 'RequestBody', parent_path:)

        properties = body_params.sort_by { |k, _| k.to_s }.map do |param_name, param_definition|
          key = transform_key(param_name)
          zod_type = map_field_definition(param_definition, action_name: nil)
          "  #{key}: #{zod_type}"
        end.join(",\n")

        "export const #{schema_name}Schema = z.object({\n#{properties}\n});"
      end

      def build_action_request_schema(resource_name, action_name, request_data, parent_path: nil)
        schema_name = action_schema_name(resource_name, action_name, 'Request', parent_path:)

        nested_properties = []

        if request_data[:query]&.any?
          query_schema_name = action_schema_name(resource_name, action_name, 'RequestQuery', parent_path:)
          nested_properties << "  query: #{query_schema_name}Schema"
        end

        if request_data[:body]&.any?
          body_schema_name = action_schema_name(resource_name, action_name, 'RequestBody', parent_path:)
          nested_properties << "  body: #{body_schema_name}Schema"
        end

        "export const #{schema_name}Schema = z.object({\n#{nested_properties.join(",\n")}\n});"
      end

      def build_action_response_body_schema(resource_name, action_name, response_body, parent_path: nil)
        schema_name = action_schema_name(resource_name, action_name, 'ResponseBody', parent_path:)

        zod_schema = map_type_definition(response_body, action_name: nil)

        "export const #{schema_name}Schema = #{zod_schema};"
      end

      def build_action_response_schema(resource_name, action_name, response_data, parent_path: nil)
        schema_name = action_schema_name(resource_name, action_name, 'Response', parent_path:)
        body_schema_name = action_schema_name(resource_name, action_name, 'ResponseBody', parent_path:)

        "export const #{schema_name}Schema = z.object({\n  body: #{body_schema_name}Schema\n});"
      end

      def action_schema_name(resource_name, action_name, suffix, parent_path: nil)
        parent_names = extract_parent_resource_names(parent_path)
        base_parts = parent_names + [resource_name.to_s, action_name.to_s]
        base_name = pascal_case(base_parts.join('_'))
        suffix_pascal = suffix.split(/(?=[A-Z])/).map(&:capitalize).join
        "#{base_name}#{suffix_pascal}"
      end

      def map_field_definition(param, action_name: nil, force_optional: nil)
        if param.type.is_a?(Symbol) && type_or_enum_reference?(param.type)
          schema_name = pascal_case(param.type)
          type = "#{schema_name}Schema"
          return apply_modifiers(type, param, action_name, force_optional:)
        end

        type = map_type_definition(param, action_name:)
        type = resolve_enum_schema(param) || type

        apply_modifiers(type, param, action_name, force_optional:)
      end

      def map_type_definition(param, action_name: nil)
        case param.type
        when :object
          map_object_type(param, action_name:)
        when :array
          map_array_type(param, action_name:)
        when :union
          map_union_type(param, action_name:)
        when :literal
          map_literal_type(param)
        when nil
          'z.never()'
        else
          result = type_or_enum_reference?(param.type) ? schema_reference(param.type) : map_primitive(param)
          resolve_enum_schema(param) || result
        end
      end

      def map_object_type(param, action_name: nil)
        return 'z.object({})' if param.shape.empty?

        partial = param.partial?

        properties = param.shape.sort_by { |name, _| name.to_s }.map do |name, field_param|
          key = transform_key(name)
          zod_type = if partial
                       map_field_definition(field_param, action_name: nil, force_optional: false)
                     else
                       map_field_definition(field_param, action_name:)
                     end
          "#{key}: #{zod_type}"
        end.join(', ')

        base_object = "z.object({ #{properties} })"
        partial ? "#{base_object}.partial()" : base_object
      end

      def map_array_type(param, action_name: nil)
        items_type = param.of

        if items_type.nil? && param.shape.any?
          items_schema = map_object_type(param, action_name:)
          return "z.array(#{items_schema})"
        end

        return 'z.array(z.string())' unless items_type

        items_schema = map_type_definition(items_type, action_name:)
        "z.array(#{items_schema})"
      end

      def map_union_type(param, action_name: nil)
        if param.discriminator
          map_discriminated_union(param, action_name:)
        else
          variants = param.variants.map { |variant| map_type_definition(variant, action_name:) }
          "z.union([#{variants.join(', ')}])"
        end
      end

      def map_discriminated_union(param, action_name: nil)
        discriminator_field = transform_key(param.discriminator)

        variant_schemas = param.variants.map { |variant| map_type_definition(variant, action_name:) }

        "z.discriminatedUnion('#{discriminator_field}', [#{variant_schemas.join(', ')}])"
      end

      def map_literal_type(param)
        case param.value
        when nil then 'z.null()'
        when String then "z.literal('#{param.value}')"
        when Numeric, TrueClass, FalseClass then "z.literal(#{param.value})"
        else "z.literal('#{param.value}')"
        end
      end

      def map_primitive(param)
        format = param.format&.to_sym if param.respond_to?(:format)

        base_type = if format
                      map_format_to_zod(format)
                    else
                      TYPE_MAP[param.type.to_sym] || 'z.unknown()'
                    end

        if numeric_type?(param.type) && param.respond_to?(:min)
          base_type += ".min(#{param.min})" if param.min
          base_type += ".max(#{param.max})" if param.max
        end

        base_type
      end

      def map_primitive_type(type_symbol)
        TYPE_MAP[type_symbol.to_sym] || 'z.unknown()'
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

      def type_or_enum_reference?(symbol)
        data.types.key?(symbol) || data.enums.key?(symbol)
      end

      def resolve_enum_schema(param)
        return nil unless param.scalar? && param.enum?

        if param.ref? && data.enums.key?(param.enum)
          "#{pascal_case(param.enum)}Schema"
        elsif param.inline?
          enum_literal = param.enum.map { |value| "'#{value}'" }.join(', ')
          "z.enum([#{enum_literal}])"
        end
      end

      def extract_parent_resource_names(parent_path)
        return [] unless parent_path

        parent_path.to_s.split('/').reject { |s| s.start_with?(':') }
      end

      def apply_modifiers(type, param, action_name, force_optional: nil)
        update = action_name.to_s == 'update'

        type += '.nullable()' if param.nullable?

        discriminator = param.literal? && !param.optional?

        optional = force_optional.nil? ? param.optional? : force_optional

        if update && !discriminator
          type += '.optional()' unless type.include?('.optional()')
        elsif optional
          type += '.optional()'
        end

        type
      end

      def numeric_type?(type)
        [:integer, :float, :decimal].include?(type&.to_sym)
      end

      def transform_key(key)
        key = key.to_s

        leading_underscore = key.start_with?('_')
        base = leading_underscore ? key[1..] : key

        transformed = case key_format
                      when :camel
                        base.camelize(:lower)
                      when :kebab
                        base.dasherize
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
