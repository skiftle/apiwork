# frozen_string_literal: true

module Apiwork
  module Spec
    class OpenAPI < Base
      KEY_ORDER = %i[openapi info servers paths components].freeze

      spec_name :openapi
      output :hash

      option :version, default: '3.1.0', enum: %w[3.1.0], type: :string
      option :key_format, default: :keep, enum: %i[keep camel underscore kebab], type: :symbol

      def generate
        {
          components: { schemas: build_schemas },
          info: build_info,
          openapi: version,
          paths: build_paths,
          servers: build_servers,
        }.slice(*KEY_ORDER).compact
      end

      private

      def build_info
        return { title: api_path, version: '1.0.0' } unless data.info

        info = data.info
        {
          contact: build_contact(info.contact),
          description: info.description,
          license: build_license(info.license),
          summary: info.summary,
          termsOfService: info.terms_of_service,
          title: info.title || api_path,
          version: info.version || '1.0.0',
        }.compact
      end

      def build_servers
        return nil unless data.info&.servers&.any?

        data.info.servers.map do |server|
          { description: server.description, url: server.url }.compact
        end
      end

      def build_contact(contact)
        return nil unless contact

        {
          email: contact.email,
          name: contact.name,
          url: contact.url,
        }.compact.presence
      end

      def build_license(license)
        return nil unless license

        {
          name: license.name,
          url: license.url,
        }.compact.presence
      end

      def build_paths
        paths = {}

        traverse_resources do |resource|
          build_resource_paths(paths, resource)
        end

        paths
      end

      def build_resource_paths(paths, resource)
        resource.actions.each do |action_name, action|
          openapi_formatted_path = openapi_path(action.path)
          method = action.method.to_s.downcase

          paths[openapi_formatted_path] ||= {}
          paths[openapi_formatted_path][method] = build_operation(
            resource,
            action_name,
            action,
          )
        end
      end

      def build_operation(resource, action_name, action)
        operation = {
          deprecated: action.deprecated? || nil,
          description: action.description,
          operationId: action.operation_id || operation_id(resource, action_name),
          summary: action.summary,
          tags: build_tags(resource.to_h[:tags], action.tags),
        }

        path_params = extract_path_parameters(action.path)

        request = action.request
        if request
          query_params = request.query? ? build_query_parameters(request.query) : []
          all_params = path_params + query_params
          operation[:parameters] = all_params if all_params.any?
          operation[:requestBody] = build_request_body(request.body) if request.body?
        elsif path_params.any?
          operation[:parameters] = path_params
        end

        operation[:responses] = build_responses(action_name, action.response, action.raises)

        operation.compact
      end

      def build_tags(resource_tags, action_tags)
        tags = []
        tags.concat(Array(resource_tags)) if resource_tags&.any?
        tags.concat(Array(action_tags)) if action_tags&.any?
        tags.any? ? tags : nil
      end

      def operation_id(resource, action_name)
        parts = resource.parent_identifiers + [resource.identifier, action_name.to_s]
        joined = parts.join('_')

        if key_format == :keep
          joined
        else
          transform_key(joined, key_format)
        end
      end

      def openapi_path(path)
        path.to_s.gsub(/:(\w+)/) { "{#{transform_key(Regexp.last_match(1))}}" }
      end

      def extract_path_parameters(path)
        return [] unless path

        path.to_s.scan(/:(\w+)/).flatten.map do |param_name|
          {
            in: 'path',
            name: transform_key(param_name),
            required: true,
            schema: { type: 'string' },
          }
        end
      end

      def build_query_parameters(query_params)
        return [] unless query_params&.any?

        query_params.map do |name, param|
          {
            in: 'query',
            name: transform_key(name),
            required: !param.optional?,
            schema: build_parameter_schema(param),
          }.tap do |result|
            result[:description] = param.description if param.description
          end
        end
      end

      def build_parameter_schema(param)
        return { '$ref': "#/components/schemas/#{schema_name(param.ref)}" } if param.ref? && type_exists?(param.ref)

        map_type_definition(param)
      end

      def build_request_body(body_params)
        {
          content: {
            'application/json': {
              schema: build_body_schema(body_params),
            },
          },
          required: true,
        }
      end

      def build_body_schema(body_params)
        properties = {}
        required_fields = []

        body_params.each do |name, param|
          transformed_key = transform_key(name)
          properties[transformed_key] = map_field(param)
          required_fields << transformed_key unless param.optional?
        end

        result = { properties:, type: 'object' }
        result[:required] = required_fields if required_fields.any?
        result
      end

      def build_responses(action_name, response, raises = [])
        responses = {}

        if response&.no_content?
          responses[:'204'] = { description: 'No content' }
        elsif response&.body
          body = response.body

          if body.union? && body.discriminator.nil?
            success_variant = body.variants[0]
            error_variant = body.variants[1]

            responses[:'200'] = {
              content: {
                'application/json': {
                  schema: map_type_definition(success_variant),
                },
              },
              description: 'Successful response',
            }

            raises.each do |code|
              error_code = data.error_codes[code]
              responses[error_code.status.to_s.to_sym] = build_union_error_response(error_code.description, error_variant)
            end
          else
            responses[:'200'] = {
              content: {
                'application/json': {
                  schema: map_type_definition(body),
                },
              },
              description: 'Successful response',
            }

            raises.each do |code|
              error_code = data.error_codes[code]
              responses[error_code.status.to_s.to_sym] = build_error_response(error_code.description)
            end
          end
        elsif response
          # Empty response {} - 200 with optional meta
          responses[:'200'] = {
            content: {
              'application/json': {
                schema: {
                  properties: {
                    meta: { type: 'object' },
                  },
                  type: 'object',
                },
              },
            },
            description: 'Successful response',
          }
        else
          # No response definition at all - default to 204
          responses[:'204'] = { description: 'No content' }
        end

        responses
      end

      def build_error_response(description)
        {
          description:,
          content: {
            'application/json': {
              schema: {
                properties: {
                  issues: {
                    items: {
                      '$ref': "#/components/schemas/#{schema_name(:error)}",
                    },
                    type: 'array',
                  },
                },
                required: ['issues'],
                type: 'object',
              },
            },
          },
        }
      end

      def build_union_error_response(description, error_variant)
        {
          description:,
          content: {
            'application/json': {
              schema: map_type_definition(error_variant),
            },
          },
        }
      end

      def build_schemas
        schemas = {}

        data.types.each do |name, type|
          component_name = schema_name(name)

          schemas[component_name] = if type.union?
                                      map_union(type)
                                    else
                                      map_object(type)
                                    end
        end

        schemas
      end

      def map_field(param)
        if param.ref? && type_exists?(param.ref)
          schema = { '$ref': "#/components/schemas/#{schema_name(param.ref)}" }
          return apply_nullable(schema, param.nullable?)
        end

        if param.scalar? && param.enum?
          if param.enum_ref? && enum_exists?(param.enum[:ref])
            enum_obj = find_enum(param.enum[:ref])
            schema = { enum: enum_obj.values, type: 'string' }
          else
            schema = { enum: param.enum, type: 'string' }
          end
          return apply_nullable(schema, param.nullable?)
        end

        schema = map_type_definition(param)

        schema[:description] = param.description if param.description
        schema[:example] = param.example if param.example
        schema[:deprecated] = true if param.deprecated?

        schema[:format] = param.format.to_s if param.respond_to?(:format) && param.format

        apply_nullable(schema, param.nullable?)
      end

      def map_type_definition(param)
        if param.object?
          map_object(param)
        elsif param.array?
          map_array(param)
        elsif param.union?
          map_union(param)
        elsif param.literal?
          map_literal(param)
        elsif param.ref? && type_exists?(param.ref)
          { '$ref': "#/components/schemas/#{schema_name(param.ref)}" }
        elsif param.ref? && enum_exists?(param.ref)
          enum_obj = find_enum(param.ref)
          { enum: enum_obj.values, type: 'string' }
        else
          map_primitive(param)
        end
      end

      def map_object(param)
        result = {
          properties: {},
          type: 'object',
        }

        result[:description] = param.description if param.description
        result[:example] = param.example if param.example

        param.shape.each do |name, field_param|
          transformed_key = transform_key(name)
          result[:properties][transformed_key] = map_field(field_param)
        end

        if param.shape.any?
          required_fields = param.shape.reject { |_, p| p.optional? }.keys.map { |k| transform_key(k) }
          result[:required] = required_fields if required_fields.any?
        end

        result
      end

      def map_array(param)
        items_param = param.of

        if items_param.nil? && param.shape.any?
          items_schema = map_inline_object(param.shape)
          return { items: items_schema, type: 'array' }
        end

        return { items: { type: 'string' }, type: 'array' } unless items_param

        items_schema = if items_param.ref? && type_exists?(items_param.ref)
                         { '$ref': "#/components/schemas/#{schema_name(items_param.ref)}" }
                       else
                         map_type_definition(items_param)
                       end

        {
          items: items_schema,
          type: 'array',
        }
      end

      def map_inline_object(shape)
        result = { properties: {}, type: 'object' }

        shape.each do |name, field_param|
          transformed_key = transform_key(name)
          result[:properties][transformed_key] = map_field(field_param)
        end

        required_fields = shape.reject { |_, p| p.optional? }.keys.map { |k| transform_key(k) }
        result[:required] = required_fields if required_fields.any?

        result
      end

      def map_union(param)
        if param.discriminator
          map_discriminated_union(param)
        else
          {
            oneOf: param.variants.map { |variant| map_type_definition(variant) },
          }
        end
      end

      def map_discriminated_union(param)
        discriminator_field = param.discriminator
        variants = param.variants

        one_of_schemas = variants.map { |variant| map_type_definition(variant) }

        mapping = {}
        variants.each do |variant|
          tag = variant.tag
          next unless tag

          transformed_tag = transform_key(tag.to_s)
          mapping[transformed_tag] = "#/components/schemas/#{schema_name(variant.ref)}" if variant.ref? && type_exists?(variant.ref)
        end

        result = { oneOf: one_of_schemas }

        result[:discriminator] = if mapping.any?
                                   {
                                     mapping:,
                                     propertyName: transform_key(discriminator_field),
                                   }
                                 else
                                   {
                                     propertyName: transform_key(discriminator_field),
                                   }
                                 end

        result
      end

      def map_literal(param)
        {
          const: param.value,
          type: openapi_type_for_value(param.value),
        }
      end

      def map_primitive(param)
        return {} if param.unknown?

        type_value = openapi_type(param.type)

        return {} if type_value.nil?

        result = { type: type_value }

        format_value = openapi_format(param.type)
        result[:format] = format_value if format_value

        if param.boundable?
          result[:minimum] = param.min if param.min
          result[:maximum] = param.max if param.max
        end

        result
      end

      def openapi_type(type)
        return nil unless type

        case type.to_sym
        when :string then 'string'
        when :integer then 'integer'
        when :float, :decimal then 'number'
        when :boolean then 'boolean'
        when :date, :datetime, :time, :uuid, :binary then 'string'
        when :json then 'object'
        when :unknown then nil
        end
      end

      def openapi_format(type)
        return nil unless type

        case type.to_sym # rubocop:disable Style/HashLikeCase
        when :float then 'double'
        when :date then 'date'
        when :datetime then 'date-time'
        when :time then 'time'
        when :uuid then 'uuid'
        when :binary then 'byte'
        end
      end

      def openapi_type_for_value(value)
        case value
        when String then 'string'
        when Integer then 'integer'
        when Float then 'number'
        when TrueClass, FalseClass then 'boolean'
        else 'string'
        end
      end

      def apply_nullable(schema, nullable)
        return schema unless nullable

        if schema[:'$ref']
          {
            oneOf: [
              schema,
              { type: 'null' },
            ],
          }
        else
          current_type = schema[:type]
          schema[:type] = [current_type, 'null']
          schema
        end
      end

      def schema_name(name)
        transform_key(name, key_format)
      end

      def type_exists?(symbol)
        return false unless symbol

        data.types.key?(symbol)
      end

      def enum_exists?(symbol)
        return false unless symbol

        data.enums.key?(symbol)
      end

      def find_enum(symbol)
        data.enums[symbol]
      end

      def traverse_resources(resources = data.resources, &block)
        resources.each_value do |resource|
          yield(resource)
          traverse_resources(resource.resources, &block) if resource.resources.any?
        end
      end
    end
  end
end
