# frozen_string_literal: true

module Apiwork
  module Spec
    class Openapi < Base
      spec_name :openapi
      content_type 'application/json'
      file_extension '.json'

      option :version, type: :string, default: '3.1.0', enum: %w[3.1.0]
      option :key_format, type: :symbol, default: :keep, enum: %i[keep camel underscore kebab]

      def generate
        {
          openapi: version,
          info: build_info,
          servers: build_servers,
          paths: build_paths,
          components: {
            schemas: build_schemas
          }
        }.compact
      end

      private

      def build_info
        info_data = data[:info] || {}

        {
          title: info_data[:title] || "#{api_path} API",
          version: info_data[:version] || '1.0.0',
          summary: info_data[:summary],
          description: info_data[:description],
          termsOfService: info_data[:terms_of_service],
          contact: build_contact(info_data[:contact]),
          license: build_license(info_data[:license])
        }.compact
      end

      def build_servers
        servers_data = data.dig(:info, :servers)
        return nil unless servers_data&.any?

        servers_data.map do |server|
          { url: server[:url], description: server[:description] }.compact
        end
      end

      def build_contact(contact_data)
        return nil unless contact_data

        {
          name: contact_data[:name],
          email: contact_data[:email],
          url: contact_data[:url]
        }.compact.presence
      end

      def build_license(license_data)
        return nil unless license_data

        {
          name: license_data[:name],
          url: license_data[:url]
        }.compact.presence
      end

      def build_paths
        paths = {}

        each_resource do |resource_name, resource_data, parent_path|
          build_resource_paths(paths, resource_name, resource_data, parent_path)
        end

        paths
      end

      def build_resource_paths(paths, resource_name, resource_data, parent_path)
        parent_paths = extract_parent_resource_paths(parent_path)

        each_action(resource_data) do |action_name, action_data|
          full_path = build_full_action_path(resource_data, action_data, parent_path)
          openapi_formatted_path = openapi_path(full_path)
          method = action_data[:method].to_s.downcase

          paths[openapi_formatted_path] ||= {}
          paths[openapi_formatted_path][method] = build_operation(
            resource_name,
            resource_data[:path],
            action_name,
            action_data,
            resource_data,
            parent_paths,
            full_path
          )
        end
      end

      def build_operation(resource_name, resource_path, action_name, action_data, resource_metadata, parent_paths = [], full_path = nil)
        operation = {
          operationId: action_data[:operation_id] || operation_id(resource_name, resource_path, action_name, parent_paths),
          summary: action_data[:summary],
          description: action_data[:description],
          tags: build_tags(resource_metadata[:tags], action_data[:tags]),
          deprecated: action_data[:deprecated] || nil
        }

        path_params = extract_path_parameters(full_path)

        request_data = action_data[:request]
        if request_data
          query_params = request_data[:query]&.any? ? build_query_parameters(request_data[:query]) : []
          all_params = path_params + query_params
          operation[:parameters] = all_params if all_params.any?
          operation[:requestBody] = build_request_body(request_data[:body], action_name) if request_data[:body]&.any?
        elsif path_params.any?
          operation[:parameters] = path_params
        end

        response_data = action_data[:response]
        operation[:responses] = build_responses(action_name, response_data, action_data[:raises] || [])

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
            name: transform_key(param_name),
            in: 'path',
            required: true,
            schema: { type: 'string' }
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
            schema: build_parameter_schema(param_definition)
          }.tap do |param|
            param[:description] = param_definition[:description] if param_definition.is_a?(Hash) && param_definition[:description]
          end
        end
      end

      def build_parameter_schema(param_definition)
        return { type: 'string' } unless param_definition.is_a?(Hash)

        if param_definition[:type].is_a?(Symbol) && types.key?(param_definition[:type])
          return { '$ref': "#/components/schemas/#{schema_name(param_definition[:type])}" }
        end

        map_type_definition(param_definition, nil)
      end

      def build_request_body(request_params, action_name)
        {
          required: true,
          content: {
            'application/json': {
              schema: build_params_object(request_params, action_name)
            }
          }
        }
      end

      def build_responses(action_name, response_data, action_raises = [])
        responses = {}
        combined_raises = (raises + action_raises).uniq

        if response_data&.dig(:no_content)
          responses[:'204'] = { description: 'No content' }
        elsif response_data&.dig(:body)
          response_params = response_data[:body]

          # Detect unwrapped union and separate success/error variants
          if response_params[:type] == :union && !response_params[:discriminator]
            success_variant = response_params[:variants][0]
            error_variant = response_params[:variants][1]

            responses[:'200'] = {
              description: 'Successful response',
              content: {
                'application/json': {
                  schema: map_type_definition(success_variant, action_name)
                }
              }
            }

            combined_raises.each do |code|
              error_data = error_codes[code]
              responses[error_data[:status].to_s.to_sym] = build_union_error_response(error_data[:description], error_variant)
            end
          else
            responses[:'200'] = {
              description: 'Successful response',
              content: {
                'application/json': {
                  schema: build_params_object(response_params)
                }
              }
            }

            combined_raises.each do |code|
              error_data = error_codes[code]
              responses[error_data[:status].to_s.to_sym] = build_error_response(error_data[:description])
            end
          end
        elsif response_data
          # Empty response {} - 200 with optional meta
          responses[:'200'] = {
            description: 'Successful response',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    meta: { type: 'object' }
                  }
                }
              }
            }
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
                type: 'object',
                properties: {
                  errors: {
                    type: 'array',
                    items: {
                      '$ref': "#/components/schemas/#{schema_name(:error)}"
                    }
                  }
                },
                required: ['errors']
              }
            }
          }
        }
      end

      def build_union_error_response(description, error_variant)
        {
          description:,
          content: {
            'application/json': {
              schema: map_type_definition(error_variant, nil)
            }
          }
        }
      end

      def build_schemas
        schemas = {}

        types.each do |type_name, type_shape|
          component_name = schema_name(type_name)

          schemas[component_name] = if type_shape.is_a?(Hash) && type_shape[:type] == :union
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

        result = { type: 'object', properties: }
        result[:required] = required_fields if required_fields.any?
        result
      end

      def map_field_definition(definition, action_name = nil)
        return { type: 'string' } unless definition.is_a?(Hash)

        if definition[:type].is_a?(Symbol) && types.key?(definition[:type])
          schema = { '$ref': "#/components/schemas/#{schema_name(definition[:type])}" }
          return apply_nullable(schema, definition[:nullable])
        end

        if definition[:type].is_a?(Symbol) && enums.key?(definition[:type])
          schema = { type: 'string', enum: enums[definition[:type]][:values] }
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
          if types.key?(type)
            { '$ref': "#/components/schemas/#{schema_name(type)}" }
          elsif enums.key?(type)
            { type: 'string', enum: enums[type][:values] }
          else
            map_primitive(definition)
          end
        end
      end

      def map_object(definition, action_name = nil)
        result = {
          type: 'object',
          properties: {}
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

        return { type: 'array', items: { type: 'string' } } unless items_type

        items_schema = if items_type.is_a?(Symbol) && types.key?(items_type)
                         { '$ref': "#/components/schemas/#{schema_name(items_type)}" }
                       elsif items_type.is_a?(Hash)
                         map_type_definition(items_type, action_name)
                       else
                         { type: openapi_type(items_type) }
                       end

        {
          type: 'array',
          items: items_schema
        }
      end

      def map_union(definition, action_name = nil)
        if definition[:discriminator]
          map_discriminated_union(definition, action_name)
        else
          {
            oneOf: definition[:variants].map { |variant| map_type_definition(variant, action_name) }
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
          if variant[:type].is_a?(Symbol) && types.key?(variant[:type])
            mapping[transformed_tag] =
              "#/components/schemas/#{schema_name(variant[:type])}"
          end
        end

        result = { oneOf: one_of_schemas }

        result[:discriminator] = if mapping.any?
                                   {
                                     propertyName: transform_key(discriminator_field),
                                     mapping:
                                   }
                                 else
                                   {
                                     propertyName: transform_key(discriminator_field)
                                   }
                                 end

        result
      end

      def map_literal(definition)
        {
          type: openapi_type_for_value(definition[:value]),
          const: definition[:value]
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
              { type: 'null' }
            ]
          }
        else
          current_type = schema[:type]
          schema[:type] = [current_type, 'null']
          schema
        end
      end

      def resolve_enum(enum_ref_or_array)
        if enum_ref_or_array.is_a?(Symbol) && enums.key?(enum_ref_or_array)
          enums[enum_ref_or_array][:values]
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
    end
  end
end
