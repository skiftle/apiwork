# frozen_string_literal: true

module Apiwork
  module Export
    class ZodMapper
      TYPE_MAP = {
        binary: 'z.string()',
        boolean: 'z.boolean()',
        date: 'z.iso.date()',
        datetime: 'z.iso.datetime()',
        decimal: 'z.number()',
        integer: 'z.number().int()',
        number: 'z.number()',
        string: 'z.string()',
        time: 'z.iso.time()',
        unknown: 'z.unknown()',
        uuid: 'z.uuid()',
      }.freeze

      class << self
        def map(export, surface)
          new(export).map(surface)
        end
      end

      def initialize(export)
        @export = export
      end

      def map(surface)
        parts = []

        enum_schemas = build_enum_schemas(surface)
        parts << enum_schemas if enum_schemas.present?

        type_schemas = build_type_schemas(surface)
        parts << type_schemas if type_schemas.present?

        action_schemas = build_action_schemas
        parts << action_schemas if action_schemas.present?

        action_response_schemas = build_action_response_schemas
        parts << action_response_schemas if action_response_schemas.present?

        parts.join("\n\n")
      end

      def build_object_schema(type_name, type, recursive: false)
        schema_name = pascal_case(type_name)

        properties = type.shape.sort_by { |name, _param| name.to_s }.map do |name, param|
          key = @export.transform_key(name)
          zod_type = map_field(param)
          "  #{key}: #{zod_type}"
        end.join(",\n")

        type_annotation = recursive ? ": z.ZodType<#{schema_name}>" : ''

        if recursive
          "export const #{schema_name}Schema#{type_annotation} = z.lazy(() => z.object({\n#{properties}\n}));"
        elsif type.extends?
          build_object_schema_code(schema_name, properties, type.extends, type_annotation:)
        else
          "export const #{schema_name}Schema#{type_annotation} = z.object({\n#{properties}\n});"
        end
      end

      def build_object_schema_code(schema_name, properties, extends, type_annotation: '')
        base_schemas = extends.map { |type| "#{pascal_case(type)}Schema" }

        base_chain = if base_schemas.size == 1
                       base_schemas.first
                     else
                       first, *rest = base_schemas
                       rest.reduce(first) { |acc, schema| "#{acc}.merge(#{schema})" }
                     end

        if properties.empty?
          "export const #{schema_name}Schema#{type_annotation} = #{base_chain};"
        else
          "export const #{schema_name}Schema#{type_annotation} = #{base_chain}.extend({\n#{properties}\n});"
        end
      end

      def build_union_schema(type_name, type, recursive: false)
        schema_name = pascal_case(type_name)

        variant_schemas = type.variants.map do |variant|
          base_schema = map_param(variant)

          if type.discriminator && variant.tag && !reference_contains_discriminator?(variant, type.discriminator)
            "#{base_schema}.extend({ #{@export.transform_key(type.discriminator)}: z.literal('#{variant.tag}') })"
          else
            base_schema
          end
        end

        union_body = variant_schemas.map { |schema| "  #{schema}" }.join(",\n")

        type_annotation = recursive ? ": z.ZodType<#{schema_name}>" : ''

        union_code = if type.discriminator
                       "z.discriminatedUnion('#{@export.transform_key(type.discriminator)}', [\n#{union_body}\n])"
                     else
                       "z.union([\n#{union_body}\n])"
                     end

        if recursive
          "export const #{schema_name}Schema#{type_annotation} = z.lazy(() => #{union_code});"
        else
          "export const #{schema_name}Schema#{type_annotation} = #{union_code};"
        end
      end

      def build_action_request_query_schema(resource_name, action_name, query_params, parent_identifiers: [])
        properties = query_params.sort_by { |name, _param| name.to_s }.map do |param_name, param|
          key = @export.transform_key(param_name)
          zod_type = map_field(param)
          "  #{key}: #{zod_type}"
        end.join(",\n")

        "export const #{action_type_name(resource_name, action_name, 'RequestQuery', parent_identifiers:)}Schema = z.object({\n#{properties}\n});"
      end

      def build_action_request_body_schema(resource_name, action_name, body_params, parent_identifiers: [])
        properties = body_params.sort_by { |name, _param| name.to_s }.map do |param_name, param|
          key = @export.transform_key(param_name)
          zod_type = map_field(param)
          "  #{key}: #{zod_type}"
        end.join(",\n")

        "export const #{action_type_name(resource_name, action_name, 'RequestBody', parent_identifiers:)}Schema = z.object({\n#{properties}\n});"
      end

      def build_action_request_schema(resource_name, action_name, request, parent_identifiers: [])
        nested_properties = []

        if request[:query].any?
          nested_properties << "  query: #{action_type_name(resource_name, action_name, 'RequestQuery', parent_identifiers:)}Schema"
        end

        if request[:body].any?
          nested_properties << "  body: #{action_type_name(resource_name, action_name, 'RequestBody', parent_identifiers:)}Schema"
        end

        "export const #{action_type_name(
          resource_name,
          action_name,
          'Request',
          parent_identifiers:,
        )}Schema = z.object({\n#{nested_properties.join(",\n")}\n});"
      end

      def build_action_response_body_schema(resource_name, action_name, response_body, parent_identifiers: [])
        "export const #{action_type_name(resource_name, action_name, 'ResponseBody', parent_identifiers:)}Schema = #{map_param(response_body)};"
      end

      def build_action_response_schema(resource_name, action_name, response, parent_identifiers: [], raises:)
        schema_name = action_type_name(resource_name, action_name, 'Response', parent_identifiers:)

        success_variant = if response.no_content?
                            'z.object({ status: z.literal(204) })'
                          else
                            body_ref = "#{action_type_name(resource_name, action_name, 'ResponseBody', parent_identifiers:)}Schema"
                            "z.object({ status: z.literal(200), body: #{body_ref} })"
                          end

        error_statuses = resolve_error_statuses(raises)

        if error_statuses.empty?
          "export const #{schema_name}Schema = #{success_variant};"
        else
          error_variants = error_statuses.map do |status|
            "z.object({ status: z.literal(#{status}), body: #{pascal_case(:error_response_body)}Schema })"
          end
          all_variants = ([success_variant] + error_variants).map { |variant| "  #{variant}" }.join(",\n")
          "export const #{schema_name}Schema = z.discriminatedUnion('status', [\n#{all_variants}\n]);"
        end
      end

      def action_type_name(resource_name, action_name, suffix, parent_identifiers: [])
        "#{pascal_case((parent_identifiers + [resource_name.to_s, action_name.to_s]).join('_'))}#{suffix.split(/(?=[A-Z])/).map(&:capitalize).join}"
      end

      def map_field(param, force_optional: nil)
        if param.reference? && type_or_enum_reference?(param.reference)
          schema_name = pascal_case(param.reference)
          type = "#{schema_name}Schema"
          return apply_modifiers(type, param, force_optional:)
        end

        type = map_param(param)
        type = resolve_enum_schema(param) || type

        apply_modifiers(type, param, force_optional:)
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
          resolve_enum_schema(param) || schema_reference(param.reference)
        else
          resolve_enum_schema(param) || map_primitive(param)
        end
      end

      def map_object_type(param)
        return 'z.record(z.string(), z.unknown())' if param.shape.empty?

        partial = param.partial?

        properties = param.shape.sort_by { |name, _field| name.to_s }.map do |name, field|
          key = @export.transform_key(name)
          zod_type = if partial
                       map_field(field, force_optional: false)
                     else
                       map_field(field)
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
          items_schema = map_param(items_type)
          base = "z.array(#{items_schema})"
        else
          base = 'z.array(z.unknown())'
        end

        base += ".min(#{param.min})" unless param.min.nil?
        base += ".max(#{param.max})" unless param.max.nil?
        base
      end

      def map_union_type(param)
        if param.discriminator
          map_discriminated_union(param)
        else
          variants = param.variants.map { |variant| map_param(variant) }
          "z.union([#{variants.join(', ')}])"
        end
      end

      def map_discriminated_union(param)
        discriminator_field = @export.transform_key(param.discriminator)

        variant_schemas = param.variants.map { |variant| map_param(variant) }

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
        return 'z.unknown()' if param.unknown?

        format = param.format&.to_sym if param.formattable?

        base_type = if format
                      map_format_to_zod(format)
                    else
                      TYPE_MAP[param.type.to_sym] || 'z.unknown()'
                    end

        if param.boundable?
          base_type += ".min(#{param.min})" unless param.min.nil?
          base_type += ".max(#{param.max})" unless param.max.nil?
        end

        base_type
      end

      def map_format_to_zod(format)
        case format
        when :email then 'z.email()'
        when :uuid then 'z.uuid()'
        when :url then 'z.url()'
        when :ipv4 then 'z.ipv4()'
        when :ipv6 then 'z.ipv6()'
        when :date then 'z.iso.date()'
        when :datetime then 'z.iso.datetime()'
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

      def build_enum_schemas(surface)
        return '' if surface.enums.empty?

        surface.enums.map do |name, enum|
          "export const #{pascal_case(name)}Schema = z.enum([#{enum.values.sort.map { |value| "'#{value}'" }.join(', ')}]);"
        end.join("\n\n")
      end

      def build_type_schemas(surface)
        types_hash = surface.types.transform_values(&:to_h)
        lazy_types = TypeAnalysis.cycle_breaking_types(types_hash)

        TypeAnalysis.topological_sort_types(types_hash).map(&:first).map do |type_name|
          type = surface.types[type_name]
          recursive = lazy_types.include?(type_name)

          if type.union?
            build_union_schema(type_name, type, recursive:)
          else
            build_object_schema(type_name, type, recursive:)
          end
        end.join("\n\n")
      end

      def build_action_schemas
        schemas = []

        traverse_resources do |resource|
          resource_name = resource.identifier.to_sym
          parent_identifiers = resource.parent_identifiers

          resource.actions.each do |action_name, action|
            request = action.request
            if request && (request.query? || request.body?)
              if request.query?
                schemas << build_action_request_query_schema(
                  resource_name,
                  action_name,
                  request.query,
                  parent_identifiers:,
                )
              end
              if request.body?
                schemas << build_action_request_body_schema(
                  resource_name,
                  action_name,
                  request.body,
                  parent_identifiers:,
                )
              end
              schemas << build_action_request_schema(
                resource_name,
                action_name,
                { body: request.body, query: request.query },
                parent_identifiers:,
              )
            end

            response = action.response
            schemas << build_action_response_body_schema(resource_name, action_name, response.body, parent_identifiers:) if response.body?
          end
        end

        schemas.join("\n\n")
      end

      def build_action_response_schemas
        schemas = []

        traverse_resources do |resource|
          resource_name = resource.identifier.to_sym
          parent_identifiers = resource.parent_identifiers

          resource.actions.each do |action_name, action|
            schemas << build_action_response_schema(resource_name, action_name, action.response, parent_identifiers:, raises: action.raises)
          end
        end

        schemas.join("\n\n")
      end

      def build_action_response_envelope_schemas
        schemas = []

        traverse_resources do |resource|
          resource_name = resource.identifier.to_sym
          parent_identifiers = resource.parent_identifiers

          resource.actions.each do |action_name, action|
            schema_name = "#{action_type_name(resource_name, action_name, 'Response', parent_identifiers:)}Schema"
            response = action.response

            schemas << if response.no_content?
                         "export const #{schema_name} = z.object({});"
                       else
                         body_ref = "#{action_type_name(resource_name, action_name, 'ResponseBody', parent_identifiers:)}Schema"
                         "export const #{schema_name} = z.object({ body: #{body_ref} });"
                       end
          end
        end

        schemas.join("\n\n")
      end

      def traverse_resources(resources: @export.api.resources, &block)
        resources.each_value do |resource|
          yield(resource)
          traverse_resources(resources: resource.resources, &block) if resource.resources.any?
        end
      end

      private

      def type_or_enum_reference?(symbol)
        @export.api.types.key?(symbol) || @export.api.enums.key?(symbol)
      end

      def reference_contains_discriminator?(variant, discriminator)
        return false unless variant.reference?

        referenced_type = @export.api.types[variant.reference]
        return false unless referenced_type

        referenced_type.shape.key?(discriminator)
      end

      def resolve_error_statuses(raises)
        raises.map { |code| @export.api.error_codes[code].status }.uniq.sort
      end

      def resolve_enum_schema(param)
        return nil unless param.scalar? && param.enum?

        if param.enum_reference? && @export.api.enums.key?(param.enum)
          "#{pascal_case(param.enum)}Schema"
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
    end
  end
end
