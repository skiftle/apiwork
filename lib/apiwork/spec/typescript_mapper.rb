# frozen_string_literal: true

module Apiwork
  module Spec
    class TypescriptMapper
      attr_reader :introspection,
                  :key_format

      def initialize(introspection:, key_format: :keep)
        @introspection = introspection
        @key_format = key_format
      end

      def build_interface(type_name, type_shape, action_name: nil, recursive: false)
        type_name_pascal = pascal_case(type_name)

        fields = type_shape[:shape] || {}

        properties = fields.sort_by { |property_name, _| property_name.to_s }.map do |property_name, property_definition|
          key = transform_key(property_name)
          update = action_name.to_s == 'update'
          optional = property_definition[:optional]

          ts_type = map_field(property_definition, action_name: action_name)
          optional_marker = update || optional ? '?' : ''
          "  #{key}#{optional_marker}: #{ts_type};"
        end.join("\n")

        if properties.empty?
          "export type #{type_name_pascal} = object;"
        else
          "export interface #{type_name_pascal} {\n#{properties}\n}"
        end
      end

      def build_union_type(type_name, type_shape)
        type_name_pascal = pascal_case(type_name)
        variants = type_shape[:variants]
        discriminator = type_shape[:discriminator]

        variant_types = variants.map do |variant|
          base_type = map_type_definition(variant, action_name: nil)

          if discriminator && variant[:tag]
            discriminator_key = transform_key(discriminator)
            "{ #{discriminator_key}: '#{variant[:tag]}' } & #{base_type}"
          else
            base_type
          end
        end

        "export type #{type_name_pascal} = #{variant_types.join(' | ')};"
      end

      def build_action_request_query_type(resource_name, action_name, query_params, parent_path: nil)
        type_name = action_type_name(resource_name, action_name, 'RequestQuery', parent_path: parent_path)

        properties = query_params.sort_by { |k, _| k.to_s }.map do |param_name, param_definition|
          key = transform_key(param_name)
          ts_type = map_field(param_definition, action_name: action_name)
          optional = param_definition[:optional]
          optional_marker = optional ? '?' : ''
          "  #{key}#{optional_marker}: #{ts_type};"
        end.join("\n")

        "export interface #{type_name} {\n#{properties}\n}"
      end

      def build_action_request_body_type(resource_name, action_name, body_params, parent_path: nil)
        type_name = action_type_name(resource_name, action_name, 'RequestBody', parent_path: parent_path)

        properties = body_params.sort_by { |k, _| k.to_s }.map do |param_name, param_definition|
          key = transform_key(param_name)
          ts_type = map_field(param_definition, action_name: action_name)
          optional = param_definition[:optional]
          optional_marker = optional ? '?' : ''
          "  #{key}#{optional_marker}: #{ts_type};"
        end.join("\n")

        "export interface #{type_name} {\n#{properties}\n}"
      end

      def build_action_request_type(resource_name, action_name, request_data, parent_path: nil)
        type_name = action_type_name(resource_name, action_name, 'Request', parent_path: parent_path)

        nested_properties = []

        if request_data[:query]&.any?
          query_type_name = action_type_name(resource_name, action_name, 'RequestQuery', parent_path: parent_path)
          nested_properties << "  query: #{query_type_name};"
        end

        if request_data[:body]&.any?
          body_type_name = action_type_name(resource_name, action_name, 'RequestBody', parent_path: parent_path)
          nested_properties << "  body: #{body_type_name};"
        end

        "export interface #{type_name} {\n#{nested_properties.join("\n")}\n}"
      end

      def build_action_response_body_type(resource_name, action_name, response_body_definition, parent_path: nil)
        type_name = action_type_name(resource_name, action_name, 'ResponseBody', parent_path: parent_path)
        ts_type = map_type_definition(response_body_definition, action_name: action_name)
        "export type #{type_name} = #{ts_type};"
      end

      def build_action_response_type(resource_name, action_name, response_data, parent_path: nil)
        type_name = action_type_name(resource_name, action_name, 'Response', parent_path: parent_path)
        body_type_name = action_type_name(resource_name, action_name, 'ResponseBody', parent_path: parent_path)
        "export interface #{type_name} {\n  body: #{body_type_name};\n}"
      end

      def action_type_name(resource_name, action_name, suffix, parent_path: nil)
        parent_names = extract_parent_resource_names(parent_path)
        base_parts = parent_names + [resource_name.to_s, action_name.to_s]
        base_name = pascal_case(base_parts.join('_'))
        "#{base_name}#{suffix.camelize}"
      end

      def map_field(definition, action_name: nil)
        return 'string' unless definition.is_a?(Hash)

        nullable = definition[:nullable]

        base_type = if definition[:type].is_a?(Symbol) && enum_or_type_reference?(definition[:type])
                      type_reference(definition[:type])
                    else
                      map_type_definition(definition, action_name: action_name)
                    end

        if definition[:enum]
          enum_reference = definition[:enum]
          if enum_reference.is_a?(Symbol) && enums.key?(enum_reference)
            base_type = pascal_case(enum_reference)
          elsif enum_reference.is_a?(Array)
            base_type = enum_reference.sort.map { |v| "'#{v}'" }.join(' | ')
          end
        end

        if nullable
          members = [base_type, 'null'].sort
          base_type = members.join(' | ')
        end

        base_type
      end

      def map_type_definition(definition, action_name: nil)
        return 'never' unless definition.is_a?(Hash)

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
          'never'
        else
          enum_or_type_reference?(type) ? type_reference(type) : map_primitive(type)
        end
      end

      def map_object_type(definition, action_name: nil)
        return 'object' unless definition[:shape]

        partial = definition[:partial]

        properties = definition[:shape].sort_by { |property_name, _| property_name.to_s }.map do |property_name, property_definition|
          key = transform_key(property_name)
          ts_type = map_field(property_definition, action_name: action_name)
          optional = property_definition[:optional]
          optional_marker = partial || optional ? '?' : ''
          "#{key}#{optional_marker}: #{ts_type}"
        end.join('; ')

        "{ #{properties} }"
      end

      def map_array_type(definition, action_name: nil)
        items_type = definition[:of]
        return 'string[]' unless items_type

        element_type = if items_type.is_a?(Symbol) && enum_or_type_reference?(items_type)
                         type_reference(items_type)
                       elsif items_type.is_a?(Hash)
                         map_type_definition(items_type, action_name: action_name)
                       else
                         map_primitive(items_type)
                       end

        if element_type.include?(' | ') || element_type.include?(' & ')
          "(#{element_type})[]"
        else
          "#{element_type}[]"
        end
      end

      def map_union_type(definition, action_name: nil)
        variants = definition[:variants].map do |variant|
          map_type_definition(variant, action_name: action_name)
        end
        variants.sort.join(' | ')
      end

      def map_literal_type(definition)
        case definition[:value]
        when nil then 'null'
        when String then "'#{definition[:value]}'"
        when Numeric, TrueClass, FalseClass then definition[:value].to_s
        else "'#{definition[:value]}'"
        end
      end

      def map_primitive(type)
        case type.to_sym
        when :string, :uuid, :date, :datetime, :time, :binary
          'string'
        when :integer, :float, :decimal
          'number'
        when :boolean
          'boolean'
        when :json
          'Record<string, any>'
        when :unknown
          'unknown'
        else
          'unknown'
        end
      end

      def type_reference(symbol)
        pascal_case(symbol)
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

      def extract_parent_resource_names(parent_path)
        return [] unless parent_path

        parent_path.to_s.split('/').reject { |s| s.start_with?(':') }
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
