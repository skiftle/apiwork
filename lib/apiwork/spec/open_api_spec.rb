# frozen_string_literal: true

module Apiwork
  module Spec
    class OpenAPISpec < Base
      spec_name :openapi
      output :hash

      option :version, default: '3.1.0', enum: %w[3.1.0], type: :string
      option :key_format, default: :keep, enum: %i[keep camel underscore kebab], type: :symbol

      def generate
        {
          components: {
            schemas: build_schemas,
          },
          info: build_info,
          openapi: version,
          paths: build_paths,
          servers: build_servers,
        }.compact
      end

      private

      def build_info
        info = data.info
        {
          contact: build_contact(info.contact),
          description: info.description,
          license: build_license(info.license),
          summary: info.summary,
          termsOfService: info.terms_of_service,
          title: info.title || "#{api_path} API",
          version: info.version || '1.0.0',
        }.compact
      end

      def build_servers
        return nil unless data.info.servers.any?

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

        data.each_resource do |resource, parent_path|
          build_resource_paths(paths, resource, parent_path)
        end

        paths
      end

      def build_resource_paths(paths, resource, parent_path)
        parent_paths = extract_parent_resource_paths(parent_path)
        resource_name = resource.identifier.to_sym

        resource.actions.each do |action_name, action|
          full_path = build_full_action_path(resource, action, parent_path)
          openapi_formatted_path = openapi_path(full_path)
          method = action.method.to_s.downcase

          paths[openapi_formatted_path] ||= {}
          paths[openapi_formatted_path][method] = build_operation(
            resource_name,
            resource,
            action_name,
            action,
            parent_paths,
            full_path,
          )
        end
      end

      def build_full_action_path(resource, action, parent_path)
        resource_path = parent_path ? "#{parent_path}/#{resource.path}" : resource.path
        "#{resource_path}#{action.path}"
      end

      def build_operation(resource_name, resource, action_name, action, parent_paths, full_path)
        operation = {
          deprecated: action.deprecated? || nil,
          description: action.description,
          operationId: action.operation_id || operation_id(resource_name, resource.path, action_name, parent_paths),
          summary: action.summary,
          tags: build_tags(resource.to_h[:tags], action.tags),
        }

        path_params = extract_path_parameters(full_path)

        request = action.request
        if request
          query_hash = request.query.transform_values(&:to_h)
          body_hash = request.body.transform_values(&:to_h)
          query_params = request.query? ? build_query_parameters(query_hash) : []
          all_params = path_params + query_params
          operation[:parameters] = all_params if all_params.any?
          operation[:requestBody] = build_request_body(body_hash, action_name) if request.body?
        elsif path_params.any?
          operation[:parameters] = path_params
        end

        response = action.response
        response_hash = response ? { body: response.body&.to_h, no_content: response.no_content? } : nil
        operation[:responses] = build_responses(action_name, response_hash, action.raises)

        operation.compact
      end

      def build_tags(resource_tags, action_tags)
        tags = []
        tags.concat(Array(resource_tags)) if resource_tags&.any?
        tags.concat(Array(action_tags)) if action_tags&.any?
        tags.any? ? tags : nil
      end

      def operation_id(_resource_name, resource_path, action_name, parent_paths = [])
        parts = parent_paths.dup

        clean_path = resource_path.to_s.split('/').last
        parts << clean_path

        parts << action_name.to_s

        joined = parts.join('_')

        if key_format == :keep
          joined
        else
          transform_key(joined, key_format)
        end
      end

      def extract_parent_resource_paths(parent_path)
        return [] unless parent_path

        parent_paths = []
        segments = parent_path.to_s.split('/')

        segments.each do |segment|
          if (match = segment.match(/:(\w+)_id/))
            parent_paths << match[1].pluralize
          elsif segment.exclude?(':')
            parent_paths << segment
          end
        end

        parent_paths
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

        query_params.map do |param_name, param_definition|
          {
            in: 'query',
            name: transform_key(param_name),
            required: param_definition.is_a?(Hash) ? !param_definition[:optional] : true,
            schema: build_parameter_schema(param_definition),
          }.tap do |param|
            param[:description] = param_definition[:description] if param_definition.is_a?(Hash) && param_definition[:description]
          end
        end
      end

      def build_parameter_schema(param_definition)
        return { type: 'string' } unless param_definition.is_a?(Hash)

        if param_definition[:type].is_a?(Symbol) && type_exists?(param_definition[:type])
          return { '$ref': "#/components/schemas/#{schema_name(param_definition[:type])}" }
        end

        map_type_definition(param_definition, nil)
      end

      def build_request_body(request_params, action_name)
        {
          content: {
            'application/json': {
              schema: build_params_object(request_params, action_name),
            },
          },
          required: true,
        }
      end

      def build_responses(action_name, response_data, action_raises = [])
        responses = {}
        combined_raises = (data.raises + action_raises).uniq

        if response_data&.dig(:no_content)
          responses[:'204'] = { description: 'No content' }
        elsif response_data&.dig(:body)
          response_params = response_data[:body]

          # Detect unwrapped union and separate success/error variants
          if response_params[:type] == :union && !response_params[:discriminator]
            success_variant = response_params[:variants][0]
            error_variant = response_params[:variants][1]

            responses[:'200'] = {
              content: {
                'application/json': {
                  schema: map_type_definition(success_variant, action_name),
                },
              },
              description: 'Successful response',
            }

            combined_raises.each do |code|
              error_code = data.error_codes[code]
              responses[error_code.status.to_s.to_sym] = build_union_error_response(error_code.description, error_variant)
            end
          else
            responses[:'200'] = {
              content: {
                'application/json': {
                  schema: build_params_object(response_params),
                },
              },
              description: 'Successful response',
            }

            combined_raises.each do |code|
              error_code = data.error_codes[code]
              responses[error_code.status.to_s.to_sym] = build_error_response(error_code.description)
            end
          end
        elsif response_data
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
              schema: map_type_definition(error_variant, nil),
            },
          },
        }
      end

      def build_schemas
        schemas = {}

        data.types.each do |name, type|
          component_name = schema_name(name)
          type_shape = type.to_h

          schemas[component_name] = if type.union?
                                      map_union(type_shape)
                                    else
                                      map_object(type_shape)
                                    end
        end

        schemas
      end

      def build_params_object(params_hash, action_name = nil)
        return map_type_definition(params_hash, action_name) unless params_hash.is_a?(Hash)

        return map_type_definition(params_hash, action_name) if params_hash.key?(:type)

        update_action = action_name.to_s == 'update'
        create_action = !update_action
        properties = {}
        required_fields = []

        params_hash.each do |param_name, param_definition|
          transformed_key = transform_key(param_name)
          properties[transformed_key] = map_field_definition(param_definition, action_name)
          required_fields << transformed_key if param_definition.is_a?(Hash) && !param_definition[:optional] && create_action
        end

        result = { properties:, type: 'object' }
        result[:required] = required_fields if required_fields.any?
        result
      end

      def map_field_definition(definition, action_name = nil)
        return { type: 'string' } unless definition.is_a?(Hash)

        if definition[:type].is_a?(Symbol) && type_exists?(definition[:type])
          schema = { '$ref': "#/components/schemas/#{schema_name(definition[:type])}" }
          return apply_nullable(schema, definition[:nullable])
        end

        if definition[:type].is_a?(Symbol) && enum_exists?(definition[:type])
          enum_obj = find_enum(definition[:type])
          schema = { enum: enum_obj.values, type: 'string' }
          return apply_nullable(schema, definition[:nullable])
        end

        schema = map_type_definition(definition, action_name)

        schema[:description] = definition[:description] if definition[:description]
        schema[:example] = definition[:example] if definition[:example]
        schema[:deprecated] = definition[:deprecated] if definition[:deprecated]

        schema[:format] = definition[:format].to_s if definition[:format]

        schema[:enum] = resolve_enum(definition[:enum]) if definition[:enum]

        apply_nullable(schema, definition[:nullable])
      end

      def map_type_definition(definition, action_name = nil)
        type = definition[:type]

        case type
        when :object
          map_object(definition, action_name)
        when :array
          map_array(definition, action_name)
        when :union
          map_union(definition, action_name)
        when :literal
          map_literal(definition)
        else
          if type_exists?(type)
            { '$ref': "#/components/schemas/#{schema_name(type)}" }
          elsif enum_exists?(type)
            enum_obj = find_enum(type)
            { enum: enum_obj.values, type: 'string' }
          else
            map_primitive(definition)
          end
        end
      end

      def map_object(definition, action_name = nil)
        result = {
          properties: {},
          type: 'object',
        }

        result[:description] = definition[:description] if definition[:description]
        result[:example] = definition[:example] if definition[:example]

        shape_fields = definition[:shape] || {}

        shape_fields.each do |property_name, property_definition|
          transformed_key = transform_key(property_name)
          result[:properties][transformed_key] = map_field_definition(property_definition, action_name)
        end

        create_action = action_name.to_s != 'update'
        if shape_fields.any? && create_action
          required_keys = shape_fields.select { |_name, prop_def| prop_def.is_a?(Hash) && !prop_def[:optional] }.keys
          required_fields = required_keys.map { |k| transform_key(k) }
          result[:required] = required_fields if required_fields.any?
        end

        result
      end

      def map_array(definition, action_name = nil)
        items_type = definition[:of]

        if items_type.nil? && definition[:shape]
          items_schema = map_object({ shape: definition[:shape], type: :object }, action_name)
          return { items: items_schema, type: 'array' }
        end

        return { items: { type: 'string' }, type: 'array' } unless items_type

        items_schema = if items_type.is_a?(Symbol) && type_exists?(items_type)
                         { '$ref': "#/components/schemas/#{schema_name(items_type)}" }
                       elsif items_type.is_a?(Hash)
                         map_type_definition(items_type, action_name)
                       else
                         { type: openapi_type(items_type) }
                       end

        {
          items: items_schema,
          type: 'array',
        }
      end

      def map_union(definition, action_name = nil)
        if definition[:discriminator]
          map_discriminated_union(definition, action_name)
        else
          {
            oneOf: definition[:variants].map { |variant| map_type_definition(variant, action_name) },
          }
        end
      end

      def map_discriminated_union(definition, action_name = nil)
        discriminator_field = definition[:discriminator]
        variants = definition[:variants]

        one_of_schemas = variants.map { |variant| map_type_definition(variant, action_name) }

        mapping = {}
        variants.each do |variant|
          tag = variant[:tag]
          next unless tag

          transformed_tag = transform_key(tag.to_s)
          if variant[:type].is_a?(Symbol) && type_exists?(variant[:type])
            mapping[transformed_tag] =
              "#/components/schemas/#{schema_name(variant[:type])}"
          end
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

      def map_literal(definition)
        {
          const: definition[:value],
          type: openapi_type_for_value(definition[:value]),
        }
      end

      def map_primitive(definition)
        return {} if definition[:type] == :unknown

        type_value = openapi_type(definition[:type])

        return {} if type_value.nil?

        result = { type: type_value }

        format_value = openapi_format(definition[:type])
        result[:format] = format_value if format_value

        if numeric_type?(definition[:type])
          result[:minimum] = definition[:min] if definition[:min]
          result[:maximum] = definition[:max] if definition[:max]
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

      def resolve_enum(enum_ref_or_array)
        if enum_ref_or_array.is_a?(Symbol) && enum_exists?(enum_ref_or_array)
          find_enum(enum_ref_or_array).values
        else
          enum_ref_or_array
        end
      end

      def schema_name(name)
        transform_key(name, key_format)
      end

      def numeric_type?(type)
        [:integer, :float, :decimal].include?(type&.to_sym)
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
    end
  end
end
