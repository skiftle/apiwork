# frozen_string_literal: true

module Apiwork
  module Export
    class TypeScriptMapper
      class << self
        def map(export, surface)
          new(export).map(surface)
        end
      end

      def initialize(export)
        @export = export
      end

      def map(surface)
        types = build_enum_types(surface.enums) +
                build_type_definitions(surface.types) +
                build_action_types +
                build_action_response_types

        types.sort_by { |entry| entry[:name] }.map { |entry| entry[:code] }.join("\n\n")
      end

      def build_interface(type_name, type)
        type_name = pascal_case(type_name)

        properties = type.shape.sort_by { |name, _param| name.to_s }.map do |name, param|
          key = @export.transform_key(name)
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

        code = build_interface_code(type_name, properties, type.extends)
        type_jsdoc ? "#{type_jsdoc}\n#{code}" : code
      end

      def build_interface_code(type_name, properties, extends)
        base_types = extends.map { |type| pascal_case(type) }

        if properties.empty? && base_types.any?
          "export type #{type_name} = #{base_types.join(' & ')};"
        elsif base_types.any?
          "export interface #{type_name} extends #{base_types.join(', ')} {\n#{properties}\n}"
        else
          "export interface #{type_name} {\n#{properties}\n}"
        end
      end

      def build_union_type(type_name, type)
        type_name = pascal_case(type_name)

        variant_types = type.variants.map do |variant|
          base_type = map_param(variant)

          if type.discriminator && variant.tag && !reference_contains_discriminator?(variant, type.discriminator)
            "{ #{@export.transform_key(type.discriminator)}: '#{variant.tag}' } & #{base_type}"
          else
            base_type
          end
        end

        code = "export type #{type_name} = #{variant_types.join(' | ')};"
        type_jsdoc = jsdoc(description: type.description)
        type_jsdoc ? "#{type_jsdoc}\n#{code}" : code
      end

      def build_enum_type(enum_name, enum)
        code = "export type #{pascal_case(enum_name)} = #{enum.values.sort.map { |value| "'#{value}'" }.join(' | ')};"
        type_jsdoc = jsdoc(description: enum.description)
        type_jsdoc ? "#{type_jsdoc}\n#{code}" : code
      end

      def build_action_request_query_type(resource_name, action_name, query_params, parent_identifiers: [])
        properties = query_params.sort_by { |name, _param| name.to_s }.map do |param_name, param|
          key = @export.transform_key(param_name)
          ts_type = map_field(param)
          optional_marker = param.optional? ? '?' : ''
          "  #{key}#{optional_marker}: #{ts_type};"
        end.join("\n")

        "export interface #{action_type_name(resource_name, action_name, 'RequestQuery', parent_identifiers:)} {\n#{properties}\n}"
      end

      def build_action_request_body_type(resource_name, action_name, body_params, parent_identifiers: [])
        properties = body_params.sort_by { |name, _param| name.to_s }.map do |param_name, param|
          key = @export.transform_key(param_name)
          ts_type = map_field(param)
          optional_marker = param.optional? ? '?' : ''
          "  #{key}#{optional_marker}: #{ts_type};"
        end.join("\n")

        "export interface #{action_type_name(resource_name, action_name, 'RequestBody', parent_identifiers:)} {\n#{properties}\n}"
      end

      def build_action_request_type(resource_name, action_name, request, parent_identifiers: [])
        nested_properties = []

        nested_properties << "  query: #{action_type_name(resource_name, action_name, 'RequestQuery', parent_identifiers:)};" if request[:query].any?

        nested_properties << "  body: #{action_type_name(resource_name, action_name, 'RequestBody', parent_identifiers:)};" if request[:body].any?

        "export interface #{action_type_name(resource_name, action_name, 'Request', parent_identifiers:)} {\n#{nested_properties.join("\n")}\n}"
      end

      def build_action_response_body_type(resource_name, action_name, response_body_definition, parent_identifiers: [])
        "export type #{action_type_name(resource_name, action_name, 'ResponseBody', parent_identifiers:)} = #{map_param(response_body_definition)};"
      end

      def build_action_response_type(resource_name, action_name, response, parent_identifiers: [], raises:)
        type_name = action_type_name(resource_name, action_name, 'Response', parent_identifiers:)

        success_variant = if response.no_content?
                            '{ status: 204 }'
                          else
                            body_ref = action_type_name(resource_name, action_name, 'ResponseBody', parent_identifiers:)
                            "{ status: 200; body: #{body_ref} }"
                          end

        error_statuses = resolve_error_statuses(raises)

        if error_statuses.empty?
          "export type #{type_name} = #{success_variant};"
        else
          error_variants = error_statuses.map { |status| "{ status: #{status}; body: #{pascal_case(:error_response_body)} }" }
          all_variants = ([success_variant] + error_variants).map { |variant| "  | #{variant}" }.join("\n")
          "export type #{type_name} =\n#{all_variants};"
        end
      end

      def action_type_name(resource_name, action_name, suffix, parent_identifiers: [])
        "#{pascal_case((parent_identifiers + [resource_name.to_s, action_name.to_s]).join('_'))}#{suffix.camelize}"
      end

      def map_field(param)
        base_type = if param.reference? && type_or_enum_reference?(param.reference)
                      type_reference(param.reference)
                    elsif param.scalar? && param.enum?
                      if param.enum_reference?
                        pascal_case(param.enum)
                      else
                        param.enum.sort.map { |value| "'#{value}'" }.join(' | ')
                      end
                    else
                      map_param(param)
                    end

        base_type = [base_type, 'null'].sort.join(' | ') if param.nullable?

        base_type
      end

      def map_param(param)
        if param.object?
          map_object_type(param)
        elsif param.array?
          map_array_type(param)
        elsif param.union?
          map_union_type(param)
        elsif param.literal?
          map_literal_type(param)
        elsif param.reference? && type_or_enum_reference?(param.reference)
          type_reference(param.reference)
        else
          map_primitive(param)
        end
      end

      def map_object_type(param)
        return 'Record<string, unknown>' if param.shape.empty?

        partial = param.object? && param.partial?

        properties = param.shape.sort_by { |name, _field| name.to_s }.map do |name, field|
          key = @export.transform_key(name)
          ts_type = map_field(field)
          optional_marker = partial || field.optional? ? '?' : ''
          "#{key}#{optional_marker}: #{ts_type}"
        end.join('; ')

        "{ #{properties} }"
      end

      def map_array_type(param)
        items_type = param.of

        return "#{map_object_type(param)}[]" if items_type.nil? && param.shape.any?

        return 'unknown[]' unless items_type

        element_type = map_param(items_type)

        if element_type.include?(' | ') || element_type.include?(' & ')
          "(#{element_type})[]"
        else
          "#{element_type}[]"
        end
      end

      def map_union_type(param)
        param.variants.map { |variant| map_param(variant) }.sort.join(' | ')
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

      def build_action_types
        types = []

        traverse_resources do |resource|
          resource_name = resource.identifier.to_sym
          parent_identifiers = resource.parent_identifiers

          resource.actions.each do |action_name, action|
            types.concat(build_request_types(resource_name, action_name, action.request, parent_identifiers:))

            response = action.response
            next unless response.body?

            type_name = action_type_name(resource_name, action_name, 'ResponseBody', parent_identifiers:)
            code = build_action_response_body_type(resource_name, action_name, response.body, parent_identifiers:)
            types << { code:, name: type_name }
          end
        end

        types
      end

      def build_action_response_types
        types = []

        traverse_resources do |resource|
          resource_name = resource.identifier.to_sym
          parent_identifiers = resource.parent_identifiers

          resource.actions.each do |action_name, action|
            type_name = action_type_name(resource_name, action_name, 'Response', parent_identifiers:)
            code = build_action_response_type(resource_name, action_name, action.response, parent_identifiers:, raises: action.raises)
            types << { code:, name: type_name }
          end
        end

        types
      end

      def traverse_resources(resources: @export.api.resources, &block)
        resources.each_value do |resource|
          yield(resource)
          traverse_resources(resources: resource.resources, &block) if resource.resources.any?
        end
      end

      def build_enum_types(enums)
        enums.map do |name, enum|
          { code: build_enum_type(name, enum), name: pascal_case(name) }
        end
      end

      def build_type_definitions(types)
        TypeAnalysis.topological_sort_types(types.transform_values(&:to_h)).map(&:first).map do |type_name|
          type = types[type_name]
          code = type.union? ? build_union_type(type_name, type) : build_interface(type_name, type)
          { code:, name: pascal_case(type_name) }
        end
      end

      private

      def resolve_error_statuses(raises)
        raises.map { |code| @export.api.error_codes[code].status }.uniq.sort
      end

      def build_request_types(resource_name, action_name, request, parent_identifiers:)
        types = []
        return types unless request && (request.query? || request.body?)

        if request.query?
          type_name = action_type_name(resource_name, action_name, 'RequestQuery', parent_identifiers:)
          code = build_action_request_query_type(resource_name, action_name, request.query, parent_identifiers:)
          types << { code:, name: type_name }
        end

        if request.body?
          type_name = action_type_name(resource_name, action_name, 'RequestBody', parent_identifiers:)
          code = build_action_request_body_type(resource_name, action_name, request.body, parent_identifiers:)
          types << { code:, name: type_name }
        end

        type_name = action_type_name(resource_name, action_name, 'Request', parent_identifiers:)
        code = build_action_request_type(resource_name, action_name, { body: request.body, query: request.query }, parent_identifiers:)
        types << { code:, name: type_name }

        types
      end

      def type_or_enum_reference?(symbol)
        @export.api.types.key?(symbol) || @export.api.enums.key?(symbol)
      end

      def reference_contains_discriminator?(variant, discriminator)
        return false unless variant.reference?

        referenced_type = @export.api.types[variant.reference]
        return false unless referenced_type

        referenced_type.shape.key?(discriminator)
      end
    end
  end
end
