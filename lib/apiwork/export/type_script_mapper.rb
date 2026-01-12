# frozen_string_literal: true

module Apiwork
  module Export
    class TypeScriptMapper
      attr_reader :data,
                  :key_format

      def initialize(data, key_format: :keep)
        @data = data
        @key_format = key_format
      end

      def build_interface(type_name, type)
        type_name_pascal = pascal_case(type_name)

        properties = type.shape.sort_by { |name, _param| name.to_s }.map do |name, param|
          key = transform_key(name)
          ts_type = map_field(param)
          optional_marker = param.optional? ? '?' : ''

          prop_jsdoc = jsdoc(description: param.description, example: param.example)
          if prop_jsdoc
            indented_jsdoc = prop_jsdoc.lines.map { |line| "  #{line.chomp}" }.join("\n")
            "#{indented_jsdoc}\n  #{key}#{optional_marker}: #{ts_type};"
          else
            "  #{key}#{optional_marker}: #{ts_type};"
          end
        end.join("\n")

        type_jsdoc = jsdoc(description: type.description, example: type.example)

        code = if properties.empty?
                 "export type #{type_name_pascal} = Record<string, unknown>;"
               else
                 "export interface #{type_name_pascal} {\n#{properties}\n}"
               end
        type_jsdoc ? "#{type_jsdoc}\n#{code}" : code
      end

      def build_union_type(type_name, type)
        type_name_pascal = pascal_case(type_name)

        variant_types = type.variants.map do |variant|
          base_type = map_type_definition(variant)

          if type.discriminator && variant.tag && !ref_contains_discriminator?(variant, type.discriminator)
            discriminator_key = transform_key(type.discriminator)
            "{ #{discriminator_key}: '#{variant.tag}' } & #{base_type}"
          else
            base_type
          end
        end

        code = "export type #{type_name_pascal} = #{variant_types.join(' | ')};"
        type_jsdoc = jsdoc(description: type.description)
        type_jsdoc ? "#{type_jsdoc}\n#{code}" : code
      end

      def build_enum_type(enum_name, enum)
        type_name = pascal_case(enum_name)
        type_literal = enum.values.sort.map { |v| "'#{v}'" }.join(' | ')

        code = "export type #{type_name} = #{type_literal};"
        type_jsdoc = jsdoc(description: enum.description)
        type_jsdoc ? "#{type_jsdoc}\n#{code}" : code
      end

      def build_action_request_query_type(resource_name, action_name, query_params, parent_identifiers: [])
        type_name = action_type_name(resource_name, action_name, 'RequestQuery', parent_identifiers:)

        properties = query_params.sort_by { |name, _param| name.to_s }.map do |param_name, param|
          key = transform_key(param_name)
          ts_type = map_field(param)
          optional_marker = param.optional? ? '?' : ''
          "  #{key}#{optional_marker}: #{ts_type};"
        end.join("\n")

        "export interface #{type_name} {\n#{properties}\n}"
      end

      def build_action_request_body_type(resource_name, action_name, body_params, parent_identifiers: [])
        type_name = action_type_name(resource_name, action_name, 'RequestBody', parent_identifiers:)

        properties = body_params.sort_by { |name, _param| name.to_s }.map do |param_name, param|
          key = transform_key(param_name)
          ts_type = map_field(param)
          optional_marker = param.optional? ? '?' : ''
          "  #{key}#{optional_marker}: #{ts_type};"
        end.join("\n")

        "export interface #{type_name} {\n#{properties}\n}"
      end

      def build_action_request_type(resource_name, action_name, request_data, parent_identifiers: [])
        type_name = action_type_name(resource_name, action_name, 'Request', parent_identifiers:)

        nested_properties = []

        if request_data[:query]&.any?
          query_type_name = action_type_name(resource_name, action_name, 'RequestQuery', parent_identifiers:)
          nested_properties << "  query: #{query_type_name};"
        end

        if request_data[:body]&.any?
          body_type_name = action_type_name(resource_name, action_name, 'RequestBody', parent_identifiers:)
          nested_properties << "  body: #{body_type_name};"
        end

        "export interface #{type_name} {\n#{nested_properties.join("\n")}\n}"
      end

      def build_action_response_body_type(resource_name, action_name, response_body_definition, parent_identifiers: [])
        type_name = action_type_name(resource_name, action_name, 'ResponseBody', parent_identifiers:)
        ts_type = map_type_definition(response_body_definition)
        "export type #{type_name} = #{ts_type};"
      end

      def build_action_response_type(resource_name, action_name, response_data, parent_identifiers: [])
        type_name = action_type_name(resource_name, action_name, 'Response', parent_identifiers:)
        body_type_name = action_type_name(resource_name, action_name, 'ResponseBody', parent_identifiers:)
        "export interface #{type_name} {\n  body: #{body_type_name};\n}"
      end

      def action_type_name(resource_name, action_name, suffix, parent_identifiers: [])
        base_parts = parent_identifiers + [resource_name.to_s, action_name.to_s]
        base_name = pascal_case(base_parts.join('_'))
        "#{base_name}#{suffix.camelize}"
      end

      def map_field(param)
        base_type = if param.ref? && type_or_enum_reference?(param.ref)
                      type_reference(param.ref)
                    elsif param.scalar? && param.enum?
                      if param.enum_ref?
                        pascal_case(param.enum)
                      else
                        param.enum.sort.map { |value| "'#{value}'" }.join(' | ')
                      end
                    else
                      map_type_definition(param)
                    end

        if param.nullable?
          members = [base_type, 'null'].sort
          base_type = members.join(' | ')
        end

        base_type
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
        elsif param.ref? && type_or_enum_reference?(param.ref)
          type_reference(param.ref)
        else
          map_primitive(param)
        end
      end

      def map_object_type(param)
        return 'Record<string, unknown>' if param.shape.empty?

        partial = param.object? && param.partial?

        properties = param.shape.sort_by { |name, _field| name.to_s }.map do |name, field_param|
          key = transform_key(name)
          ts_type = map_field(field_param)
          optional_marker = partial || field_param.optional? ? '?' : ''
          "#{key}#{optional_marker}: #{ts_type}"
        end.join('; ')

        "{ #{properties} }"
      end

      def map_array_type(param)
        items_type = param.of

        if items_type.nil? && param.shape.any?
          element_type = map_object_type(param)
          return "#{element_type}[]"
        end

        return 'unknown[]' unless items_type

        element_type = map_type_definition(items_type)

        if element_type.include?(' | ') || element_type.include?(' & ')
          "(#{element_type})[]"
        else
          "#{element_type}[]"
        end
      end

      def map_union_type(param)
        variants = param.variants.map do |variant|
          map_type_definition(variant)
        end
        variants.sort.join(' | ')
      end

      def map_literal_type(param)
        case param.value
        when nil then 'null'
        when String then "'#{param.value}'"
        when Numeric, TrueClass, FalseClass then param.value.to_s
        else "'#{param.value}'"
        end
      end

      def map_primitive(param)
        return 'unknown' if param.unknown?
        return 'string' if param.string? || param.uuid? || param.date? || param.datetime? || param.time? || param.binary?
        return 'number' if param.numeric?
        return 'boolean' if param.boolean?
        return 'Record<string, unknown>' if param.json?

        'unknown'
      end

      def type_reference(symbol)
        pascal_case(symbol)
      end

      def pascal_case(name)
        name.to_s.camelize(:upper)
      end

      def jsdoc(description: nil, example: nil)
        return nil if description.nil? && example.nil?
        return "/** #{description} */" if description && example.nil?

        lines = ['/**']
        lines << " * #{description}" if description
        lines << " * @example #{format_example(example)}" if example
        lines << ' */'
        lines.join("\n")
      end

      def format_example(value)
        case value
        when Hash, Array
          value.to_json
        when String
          "\"#{value}\""
        else
          value.to_s
        end
      end

      private

      def type_or_enum_reference?(symbol)
        data.types.key?(symbol) || data.enums.key?(symbol)
      end

      def ref_contains_discriminator?(variant, discriminator)
        return false unless variant.ref?

        referenced_type = data.types[variant.ref]
        return false unless referenced_type

        referenced_type.shape.key?(discriminator)
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
