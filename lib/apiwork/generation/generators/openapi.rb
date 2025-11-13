# frozen_string_literal: true

module Apiwork
  module Generation
    module Generators
      # OpenAPI 3.1 generator using API introspection
      #
      # Generates OpenAPI 3.1 specifications from API introspection data.
      # Uses introspection data directly - all types become components with $ref.
      #
      # Available at: GET /api/v1/.spec/openapi
      #
      # @example Generate OpenAPI spec
      #   generator = OpenAPI.new('/api/v1')
      #   spec = generator.generate
      #   File.write('openapi.json', JSON.pretty_generate(spec))
      #
      # @example Specify version explicitly
      #   generator = OpenAPI.new('/api/v1', version: '3.1.0')
      #   spec = generator.generate
      class OpenAPI < Base
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

        # Generate OpenAPI specification
        #
        # @return [Hash] OpenAPI specification
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

        # Build OpenAPI info object from API metadata
        def build_info
          meta = metadata || {}

          {
            title: meta[:title] || "#{path} API",
            version: meta[:version] || '1.0.0',
            description: meta[:description]
          }.compact
        end

        # Build OpenAPI paths from all resources
        def build_paths
          paths = {}

          each_resource do |resource_name, resource_data, parent_path|
            build_resource_paths(paths, resource_name, resource_data, parent_path)
          end

          paths
        end

        # Build paths for a single resource
        def build_resource_paths(paths, resource_name, resource_data, parent_path)
          # Extract all parent resource paths from parent_path (supports deep nesting)
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

        # Build OpenAPI operation object
        def build_operation(resource_name, resource_path, action_name, action_data, parent_paths = [])
          operation = {
            operationId: operation_id(resource_name, resource_path, action_name, parent_paths),
            tags: [resource_name.to_s.singularize.camelize],
            responses: build_responses(action_name, action_data[:output], action_data[:error_codes] || [])
          }

          # Add requestBody if action has input
          operation[:requestBody] = build_request_body(action_data[:input], action_name) if action_data[:input]

          operation.compact
        end

        # Build operation ID
        # Format: resource_action or parent1_parent2_resource_action for nested resources
        # Uses plural/singular based on resource path (e.g., "posts" -> posts_index, "account" -> account_show)
        # Applies key_transform for consistency
        # Supports deep nesting: accounts/:account_id/shifts/:shift_id/breaks -> account_shift_break_index
        # For camelCase transforms, concatenates without underscores (e.g., accountsLeaveRequestsApprove)
        def operation_id(_resource_name, resource_path, action_name, parent_paths = [])
          # Build parts array starting with parent paths (in snake_case)
          parts = parent_paths.dup

          # Add current resource path (remove any path parameters)
          clean_path = resource_path.to_s.split('/').last
          parts << clean_path

          # Add action name
          parts << action_name.to_s

          # Join all parts with underscore
          joined = parts.join('_')

          # For :none, return as-is (snake_case with underscores)
          # For camelCase variants, transform the joined string
          if key_transform == :none
            joined
          else
            # Apply transform to get proper camelCase (removes underscores)
            transform_key(joined, key_transform)
          end
        end

        # Extract all parent resource paths from parent_path (supports deep nesting)
        # e.g., "posts/:post_id/comments" -> ["posts"]
        # e.g., "accounts/:account_id/shifts/:shift_id/breaks" -> ["accounts", "shifts"]
        # e.g., ":post_id/comments" -> ["posts"] (pluralize from :post_id)
        def extract_parent_resource_paths(parent_path)
          return [] unless parent_path

          parent_paths = []
          segments = parent_path.to_s.split('/')

          segments.each do |segment|
            # If segment is a path parameter like :post_id, extract and pluralize
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

        # Build OpenAPI requestBody from action input
        # For update actions (PATCH), all fields are optional even if marked required
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

        # Build OpenAPI responses from action output
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

        # Build error response with Error schema reference
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
                    errors: {
                      type: 'array',
                      items: {
                        '$ref': "#/components/schemas/#{schema_name(:error)}"
                      }
                    }
                  },
                  required: %w[ok errors]
                }
              }
            }
          }
        end

        # Get error description for status code
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

        # Build all component schemas from types
        def build_schemas
          schemas = {}

          types.each do |type_name, type_shape|
            component_name = schema_name(type_name)

            # Check if this is a union type
            schemas[component_name] = if type_shape.is_a?(Hash) && type_shape[:type] == :union
                                        # Handle union types directly
                                        map_union(type_shape)
                                      else
                                        # Regular object type - wrap as object
                                        map_object({ shape: type_shape })
                                      end
          end

          schemas
        end

        # Build object schema from params hash
        # Wraps { param_name => param_def } into OpenAPI object schema
        # For update actions, all fields become optional
        def build_params_object(params_hash, action_name = nil)
          # If params_hash is not a Hash, treat it as a type definition
          return map_type_definition(params_hash, action_name) unless params_hash.is_a?(Hash)

          # If params_hash has :type key, it's a type definition, not a params hash
          return map_type_definition(params_hash, action_name) if params_hash.key?(:type)

          is_update_action = action_name.to_s == 'update'
          properties = {}
          required_fields = []

          params_hash.each do |param_name, param_def|
            transformed_key = transform_key(param_name)
            properties[transformed_key] = map_field_definition(param_def, action_name)
            # For update actions, never mark fields as required
            required_fields << transformed_key if param_def.is_a?(Hash) && param_def[:required] && !is_update_action
          end

          result = { type: 'object', properties: }
          result[:required] = required_fields if required_fields.any?
          result
        end

        # Map a field definition (handles type references, inline types, enums)
        def map_field_definition(definition, action_name = nil)
          # Ensure definition is a Hash
          return { type: 'string' } unless definition.is_a?(Hash)

          # Handle custom type references
          if definition[:type].is_a?(Symbol) && types.key?(definition[:type])
            schema = { '$ref': "#/components/schemas/#{schema_name(definition[:type])}" }
            return apply_nullable(schema, definition[:nullable])
          end

          # Map inline type
          schema = map_type_definition(definition, action_name)

          # Handle enum references or inline enums
          schema[:enum] = resolve_enum(definition[:enum]) if definition[:enum]

          apply_nullable(schema, definition[:nullable])
        end

        # Map type definition to OpenAPI schema
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

        # Map object type to OpenAPI schema
        # For update actions, all nested fields are also optional
        def map_object(definition, action_name = nil)
          is_update_action = action_name.to_s == 'update'
          result = {
            type: 'object',
            properties: {}
          }

          # Map each property in shape
          definition[:shape]&.each do |property_name, property_def|
            transformed_key = transform_key(property_name)
            result[:properties][transformed_key] = map_field_definition(property_def, action_name)
          end

          # Collect required fields from shape (skip for update actions)
          if definition[:shape] && !is_update_action
            required_keys = definition[:shape].select { |_name, prop_def| prop_def[:required] }.keys
            required_fields = required_keys.map { |k| transform_key(k) }
            result[:required] = required_fields if required_fields.any?
          end

          result
        end

        # Map array type to OpenAPI schema
        def map_array(definition, action_name = nil)
          items_type = definition[:of]

          # Handle missing :of
          return { type: 'array', items: { type: 'string' } } unless items_type

          # If :of is a custom type reference, use $ref
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

        # Map union type to OpenAPI oneOf (with discriminator support)
        def map_union(definition, action_name = nil)
          if definition[:discriminator]
            map_discriminated_union(definition, action_name)
          else
            {
              oneOf: definition[:variants].map { |variant| map_type_definition(variant, action_name) }
            }
          end
        end

        # Map discriminated union with OpenAPI discriminator
        def map_discriminated_union(definition, action_name = nil)
          discriminator_field = definition[:discriminator]
          variants = definition[:variants]

          # Build oneOf with all variant schemas
          one_of_schemas = variants.map { |variant| map_type_definition(variant, action_name) }

          # Build discriminator mapping if variants have tags
          mapping = {}
          variants.each do |variant|
            tag = variant[:tag]
            next unless tag

            # If variant is a custom type reference, use $ref
            mapping[tag.to_s] = "#/components/schemas/#{schema_name(variant[:type])}" if variant[:type].is_a?(Symbol) && types.key?(variant[:type])
          end

          result = { oneOf: one_of_schemas }

          # Add discriminator with mapping if available
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

        # Map literal type to OpenAPI const
        def map_literal(definition)
          {
            type: openapi_type_for_value(definition[:value]),
            const: definition[:value]
          }
        end

        # Map primitive type to OpenAPI schema
        def map_primitive(definition)
          {
            type: openapi_type(definition[:type])
          }
        end

        # Convert contract type to OpenAPI type
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

        # Determine OpenAPI type from a value (for literals)
        def openapi_type_for_value(value)
          case value
          when String then 'string'
          when Integer then 'integer'
          when Float then 'number'
          when TrueClass, FalseClass then 'boolean'
          else 'string'
          end
        end

        # Apply nullable to a schema
        # OpenAPI 3.1: use type array ['string', 'null']
        def apply_nullable(schema, nullable)
          return schema unless nullable

          # If schema has $ref, wrap it in oneOf
          if schema[:'$ref']
            {
              oneOf: [
                schema,
                { type: 'null' }
              ]
            }
          else
            # Add null to type array
            current_type = schema[:type]
            schema[:type] = [current_type, 'null']
            schema
          end
        end

        # Resolve enum reference or return inline enum array
        def resolve_enum(enum_ref_or_array)
          if enum_ref_or_array.is_a?(Symbol) && enums.key?(enum_ref_or_array)
            enums[enum_ref_or_array]
          else
            enum_ref_or_array
          end
        end

        # Get schema name using key transformation
        # Uses key_transform option directly - :none means leave as-is (underscore)
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
      end
    end
  end
end
