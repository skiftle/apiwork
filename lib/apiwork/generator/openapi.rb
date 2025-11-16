# frozen_string_literal: true

module Apiwork
  module Generator
    class Openapi < Base
      generator_name :openapi
      content_type 'application/json'

      VALID_VERSIONS = ['3.1.0'].freeze

      def self.file_extension
        '.json'
      end

      def self.default_options
        { version: '3.1.0' }
      end

      def initialize(path, **options)
        super
        validate_version!
      end

      def generate
        {
          openapi: version,
          info: build_info,
          paths: build_paths,
          components: {
            schemas: build_schemas
          }
        }.compact
      end

      private

      def build_info
        meta = metadata || {}

        {
          title: meta[:title] || "#{path} API",
          version: meta[:version] || '1.0.0',
          description: meta[:description]
        }.compact
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
          method = action_data[:method].to_s.downcase

          paths[full_path] ||= {}
          paths[full_path][method] = build_operation(
            resource_name,
            resource_data[:path],
            action_name,
            action_data,
            parent_paths
          )
        end
      end

      def build_operation(resource_name, resource_path, action_name, action_data, parent_paths = [])
        operation = {
          operationId: operation_id(resource_name, resource_path, action_name, parent_paths),
          tags: [resource_name.to_s.singularize.camelize],
          responses: build_responses(action_name, action_data[:output], action_data[:error_codes] || [])
        }

        operation[:requestBody] = build_request_body(action_data[:input], action_name) if action_data[:input]

        operation.compact
      end

      def operation_id(_resource_name, resource_path, action_name, parent_paths = [])
        parts = parent_paths.dup

        clean_path = resource_path.to_s.split('/').last
        parts << clean_path

        parts << action_name.to_s

        # Join all parts with underscore
        joined = parts.join('_')

        if key_transform == :keep
          joined
        else
          transform_key(joined, key_transform)
        end
      end

      def extract_parent_resource_paths(parent_path)
        return [] unless parent_path

        parent_paths = []
        segments = parent_path.to_s.split('/')

        segments.each do |segment|
          if segment.match?(/:(\w+)_id/)
            match = segment.match(/:(\w+)_id/)
            parent_paths << match[1].pluralize if match
          elsif segment.match?(/:/).nil?
            # Regular path segment (not a parameter)
            parent_paths << segment
          end
        end

        parent_paths
      end

      def build_request_body(input_params, action_name)
        {
          required: true,
          content: {
            'application/json': {
              schema: build_params_object(input_params, action_name)
            }
          }
        }
      end

      def build_responses(_action_name, output_params, action_error_codes = [])
        responses = {}

        # Success response
        if output_params
          responses[:'200'] = {
            description: 'Successful response',
            content: {
              'application/json': {
                schema: build_params_object(output_params)
              }
            }
          }
        else
          responses[:'204'] = {
            description: 'No content'
          }
        end

        # Error responses from global + action-level error codes
        combined_error_codes = (error_codes + action_error_codes).uniq.sort
        combined_error_codes.each do |code|
          responses[code.to_s.to_sym] = build_error_response(code)
        end

        responses
      end

      def build_error_response(code)
        {
          description: error_description(code),
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  ok: {
                    type: 'boolean',
                    const: false
                  },
                  issues: {
                    type: 'array',
                    items: {
                      '$ref': "#/components/schemas/#{schema_name(:issue)}"
                    }
                  }
                },
                required: %w[ok issues]
              }
            }
          }
        }
      end

      def error_description(code)
        case code
        when 400 then 'Bad Request'
        when 401 then 'Unauthorized'
        when 403 then 'Forbidden'
        when 404 then 'Not Found'
        when 422 then 'Unprocessable Entity'
        when 500 then 'Internal Server Error'
        else "Error #{code}"
        end
      end

      def build_schemas
        schemas = {}

        types.each do |type_name, type_shape|
          component_name = schema_name(type_name)

          schemas[component_name] = if type_shape.is_a?(Hash) && type_shape[:type] == :union
                                      map_union(type_shape)
                                    else
                                      # Regular object type - wrap as object
                                      map_object({ shape: type_shape })
                                    end
        end

        schemas
      end

      def build_params_object(params_hash, action_name = nil)
        return map_type_definition(params_hash, action_name) unless params_hash.is_a?(Hash)

        return map_type_definition(params_hash, action_name) if params_hash.key?(:type)

        is_update_action = action_name.to_s == 'update'
        is_create_action = !is_update_action
        properties = {}
        required_fields = []

        params_hash.each do |param_name, param_def|
          transformed_key = transform_key(param_name)
          properties[transformed_key] = map_field_definition(param_def, action_name)
          required_fields << transformed_key if param_def.is_a?(Hash) && param_def[:required] && is_create_action
        end

        result = { type: 'object', properties: }
        result[:required] = required_fields if required_fields.any?
        result
      end

      def map_field_definition(definition, action_name = nil)
        # Ensure definition is a Hash
        return { type: 'string' } unless definition.is_a?(Hash)

        if definition[:type].is_a?(Symbol) && types.key?(definition[:type])
          schema = { '$ref': "#/components/schemas/#{schema_name(definition[:type])}" }
          return apply_nullable(schema, definition[:nullable])
        end

        schema = map_type_definition(definition, action_name)

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
          # Primitive or custom type reference
          if types.key?(type)
            { '$ref': "#/components/schemas/#{schema_name(type)}" }
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

        definition[:shape]&.each do |property_name, property_def|
          transformed_key = transform_key(property_name)
          result[:properties][transformed_key] = map_field_definition(property_def, action_name)
        end

        # Collect required fields from shape (skip for update actions)
        is_create_action = action_name.to_s != 'update'
        if definition[:shape] && is_create_action
          required_keys = definition[:shape].select { |_name, prop_def| prop_def[:required] }.keys
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
                         # Nested inline type
                         map_type_definition(items_type, action_name)
                       else
                         # Primitive type
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

          mapping[tag.to_s] = "#/components/schemas/#{schema_name(variant[:type])}" if variant[:type].is_a?(Symbol) && types.key?(variant[:type])
        end

        result = { oneOf: one_of_schemas }

        result[:discriminator] = if mapping.any?
                                   {
                                     propertyName: discriminator_field.to_s,
                                     mapping:
                                   }
                                 else
                                   # No mapping, just propertyName
                                   {
                                     propertyName: discriminator_field.to_s
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
        result = { type: openapi_type(definition[:type]) }

        # Add numeric constraints for OpenAPI 3.1
        if numeric_type?(definition[:type])
          result[:minimum] = definition[:min] if definition[:min]
          result[:maximum] = definition[:max] if definition[:max]
        end

        result
      end

      def openapi_type(type)
        return 'string' unless type # Default for nil

        case type.to_sym
        when :string, :text then 'string'
        when :integer then 'integer'
        when :float, :decimal, :number then 'number'
        when :boolean then 'boolean'
        when :date, :datetime, :time, :uuid then 'string'
        when :json then 'object'
        when :binary then 'string'
        else 'string' # Default fallback
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

      # OpenAPI 3.1: use type array ['string', 'null']
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
          enums[enum_ref_or_array]
        else
          enum_ref_or_array
        end
      end

      def schema_name(name)
        transform_key(name, key_transform)
      end

      # Validate version option
      def validate_version!
        return if version.nil?

        return if VALID_VERSIONS.include?(version)

        raise ArgumentError,
              "Invalid version for openapi: #{version.inspect}. " \
              "Valid versions: #{VALID_VERSIONS.join(', ')}"
      end

      # Check if a type is numeric
      def numeric_type?(type)
        [:integer, :float, :decimal, :number].include?(type&.to_sym)
      end
    end
  end
end
