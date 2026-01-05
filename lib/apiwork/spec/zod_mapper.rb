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

      def build_object_schema(type_name, type, recursive: false)
        schema_name = pascal_case(type_name)

        properties = type.shape.sort_by { |name, _| name.to_s }.map do |name, param|
          key = transform_key(name)
          zod_type = map_field(param)
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

        variant_schemas = type.variants.map { |variant| map_type_definition(variant) }
        union_body = variant_schemas.map { |v| "  #{v}" }.join(",\n")

        if type.discriminator
          discriminator_key = transform_key(type.discriminator)
          "export const #{schema_name}Schema = z.discriminatedUnion('#{discriminator_key}', [\n#{union_body}\n]);"
        else
          "export const #{schema_name}Schema = z.union([\n#{union_body}\n]);"
        end
      end

      def build_action_request_query_schema(resource_name, action_name, query_params, parent_identifiers: [])
        schema_name = action_type_name(resource_name, action_name, 'RequestQuery', parent_identifiers:)

        properties = query_params.sort_by { |k, _| k.to_s }.map do |param_name, param_definition|
          key = transform_key(param_name)
          zod_type = map_field(param_definition)
          "  #{key}: #{zod_type}"
        end.join(",\n")

        "export const #{schema_name}Schema = z.object({\n#{properties}\n});"
      end

      def build_action_request_body_schema(resource_name, action_name, body_params, parent_identifiers: [])
        schema_name = action_type_name(resource_name, action_name, 'RequestBody', parent_identifiers:)

        properties = body_params.sort_by { |k, _| k.to_s }.map do |param_name, param_definition|
          key = transform_key(param_name)
          zod_type = map_field(param_definition)
          "  #{key}: #{zod_type}"
        end.join(",\n")

        "export const #{schema_name}Schema = z.object({\n#{properties}\n});"
      end

      def build_action_request_schema(resource_name, action_name, request_data, parent_identifiers: [])
        schema_name = action_type_name(resource_name, action_name, 'Request', parent_identifiers:)

        nested_properties = []

        if request_data[:query]&.any?
          query_schema_name = action_type_name(resource_name, action_name, 'RequestQuery', parent_identifiers:)
          nested_properties << "  query: #{query_schema_name}Schema"
        end

        if request_data[:body]&.any?
          body_schema_name = action_type_name(resource_name, action_name, 'RequestBody', parent_identifiers:)
          nested_properties << "  body: #{body_schema_name}Schema"
        end

        "export const #{schema_name}Schema = z.object({\n#{nested_properties.join(",\n")}\n});"
      end

      def build_action_response_body_schema(resource_name, action_name, response_body, parent_identifiers: [])
        schema_name = action_type_name(resource_name, action_name, 'ResponseBody', parent_identifiers:)

        zod_schema = map_type_definition(response_body)

        "export const #{schema_name}Schema = #{zod_schema};"
      end

      def build_action_response_schema(resource_name, action_name, response_data, parent_identifiers: [])
        schema_name = action_type_name(resource_name, action_name, 'Response', parent_identifiers:)
        body_schema_name = action_type_name(resource_name, action_name, 'ResponseBody', parent_identifiers:)

        "export const #{schema_name}Schema = z.object({\n  body: #{body_schema_name}Schema\n});"
      end

      def action_type_name(resource_name, action_name, suffix, parent_identifiers: [])
        base_parts = parent_identifiers + [resource_name.to_s, action_name.to_s]
        base_name = pascal_case(base_parts.join('_'))
        suffix_pascal = suffix.split(/(?=[A-Z])/).map(&:capitalize).join
        "#{base_name}#{suffix_pascal}"
      end

      def map_field(param, force_optional: nil)
        if param.ref_type? && type_or_enum_reference?(param.ref)
          schema_name = pascal_case(param.ref)
          type = "#{schema_name}Schema"
          return apply_modifiers(type, param, force_optional:)
        end

        type = map_type_definition(param)
        type = resolve_enum_schema(param) || type

        apply_modifiers(type, param, force_optional:)
      end

      def map_type_definition(param)
        if param.object?
          map_object_type(param)
        elsif param.array?
          map_array_type(param)
        elsif param.union?
          map_union_type(param)
        elsif param.literal?
          map_literal_type(param)
        elsif param.ref_type? && type_or_enum_reference?(param.ref)
          resolve_enum_schema(param) || schema_reference(param.ref)
        else
          resolve_enum_schema(param) || map_primitive(param)
        end
      end

      def map_object_type(param)
        return 'z.object({})' if param.shape.empty?

        partial = param.respond_to?(:partial?) && param.partial?

        properties = param.shape.sort_by { |name, _| name.to_s }.map do |name, field_param|
          key = transform_key(name)
          zod_type = if partial
                       map_field(field_param, force_optional: false)
                     else
                       map_field(field_param)
                     end
          "#{key}: #{zod_type}"
        end.join(', ')

        base_object = "z.object({ #{properties} })"
        partial ? "#{base_object}.partial()" : base_object
      end

      def map_array_type(param)
        items_type = param.of

        if items_type.nil? && param.shape.any?
          items_schema = map_object_type(param)
          base = "z.array(#{items_schema})"
        elsif items_type
          items_schema = map_type_definition(items_type)
          base = "z.array(#{items_schema})"
        else
          base = 'z.array(z.string())'
        end

        base += ".min(#{param.min})" if param.respond_to?(:min) && param.min
        base += ".max(#{param.max})" if param.respond_to?(:max) && param.max
        base
      end

      def map_union_type(param)
        if param.discriminator
          map_discriminated_union(param)
        else
          variants = param.variants.map { |variant| map_type_definition(variant) }
          "z.union([#{variants.join(', ')}])"
        end
      end

      def map_discriminated_union(param)
        discriminator_field = transform_key(param.discriminator)

        variant_schemas = param.variants.map { |variant| map_type_definition(variant) }

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
        format = param.format&.to_sym if param.formattable?

        base_type = if format
                      map_format_to_zod(format)
                    else
                      TYPE_MAP[param.type.to_sym] || 'z.unknown()'
                    end

        if param.boundable?
          base_type += ".min(#{param.min})" if param.min
          base_type += ".max(#{param.max})" if param.max
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

      def type_or_enum_reference?(symbol)
        data.types.key?(symbol) || data.enums.key?(symbol)
      end

      def resolve_enum_schema(param)
        return nil unless param.scalar? && param.enum?

        if param.ref_enum? && data.enums.key?(param.enum[:ref])
          "#{pascal_case(param.enum[:ref])}Schema"
        else
          enum_literal = param.enum.map { |value| "'#{value}'" }.join(', ')
          "z.enum([#{enum_literal}])"
        end
      end

      def apply_modifiers(type, param, force_optional: nil)
        type += '.nullable()' if param.nullable?
        optional = force_optional.nil? ? param.optional? : force_optional
        type += '.optional()' if optional
        type
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
