# frozen_string_literal: true

module Apiwork
  module Generation
    class Transport < Base
      generator_name :transport
      content_type 'text/plain; charset=utf-8'

      def self.file_extension
        '.ts'
      end

      def initialize(path, key_transform: :camelize_lower, builders: false, **options)
        @path = path
        @key_transform = key_transform
        @builders = builders
        @options = options

        # Load data from APIInspector
        @resources = APIInspector.resources(path: path)
        @routes = APIInspector.routes(path: path)
        @inputs = APIInspector.inputs(path: path)
      end

      def needs_resources?
        true
      end

      def needs_routes?
        true
      end

      def needs_inputs?
        true
      end

      def generate
        # 1. Validate that all schemas in API exist
        validate_api_schemas_from_inspector(@resources, @path)

        # 2. Collect enum schemas BEFORE generating Zod schemas
        enum_definitions = collect_enum_schemas(@resources, @key_transform)

        # 3. Generate Zod schemas for all schemas
        zod_schemas = Zod.generate_schemas_only(@resources, key_transform: @key_transform)

        # 4. Generate Input Zod schemas
        input_zod_schemas = generate_input_schemas_from_inspector(@inputs, @key_transform)

        # 5. Build contract structure from routes metadata
        result = build_contract_structure_from_routes(@routes, zod_schemas, @key_transform)
        contract_structure = result[:contract]
        output_schemas = result[:output_schemas]
        input_schemas = result[:input_schemas]

        # 6. Generate TypeScript document
        build_typescript_document(
          contract_structure,
          zod_schemas,
          @key_transform,
          builders: @builders,
          enum_definitions: enum_definitions,
          input_schemas: input_zod_schemas,
          endpoint_input_schemas: generate_input_schemas_for_endpoints(input_schemas),
          output_schemas: generate_output_schemas(output_schemas)
        )
      end

      private

      # NOTE: Migrated from ResourceInspector - directly describe a resource class
      # This provides metadata about a resource class similar to ResourceInspector.describe_class
      def describe_resource_class(resource_class)
        namespaces = resource_class.name.deconstantize.split('::').map(&:underscore).reject(&:blank?)
        name = resource_class.name.demodulize.sub(/Resource$/, '').underscore

        {
          namespaces: namespaces,
          name: name,
          type: resource_class.type,
          root_key: resource_class.root_key.to_s,
          attributes: extract_attributes_from_resource(resource_class),
          associations: extract_associations_from_resource(resource_class)
        }
      end

      # Extract attributes metadata from resource class
      def extract_attributes_from_resource(resource_class)
        model = resource_class.model_class
        columns = model&.columns_hash || {}

        resource_class.attribute_definitions.each_with_object({}) do |(attr, opts), acc|
          col = columns[attr.to_s]
          acc[attr.to_s] = {
            type: normalize_attribute_type(opts[:type]),
            nullable: col ? col.null : true,
            filterable: opts[:filterable].present?,
            sortable: opts[:sortable].present?,
            writable: writable_descriptor(opts[:writable]),
            required: opts[:required].present?,
            enum: opts[:enum]
          }.compact
        end
      end

      # Extract associations metadata from resource class
      def extract_associations_from_resource(resource_class)
        model = resource_class.model_class

        resource_class.association_definitions.each_with_object({}) do |(assoc, defn), acc|
          reflection = model&.reflect_on_association(assoc)
          target_ns, target_name = resolve_association_target(resource_class, defn, reflection)

          acc[assoc.to_s] = {
            kind: defn[:type].to_s,
            namespaces: target_ns,
            name: target_name,
            nullable: association_nullable?(reflection),
            polymorphic: reflection&.polymorphic? || false,
            writable: writable_descriptor(defn[:writable]),
            serializable: defn.serializable? || false
          }
        end
      end

      # Resolve association target resource name
      def resolve_association_target(resource_class, assoc_def, reflection)
        if assoc_def.resource_class
          ns = assoc_def.resource_class.name.deconstantize.split('::').map(&:underscore).reject(&:blank?)
          nm = assoc_def.resource_class.name.demodulize.sub(/Resource$/, '').underscore
          return [ns, nm]
        end

        if reflection&.klass
          ns = resource_class.name.deconstantize.split('::').map(&:underscore).reject(&:blank?)
          nm = reflection.klass.name.underscore
          return [ns, nm]
        end

        [[], '']
      end

      # Check if association is nullable
      def association_nullable?(reflection)
        return true unless reflection
        return reflection.options[:optional] != false if reflection.macro == :belongs_to

        true
      end

      # Normalize attribute type to standard types
      def normalize_attribute_type(type)
        sym = type&.to_sym
        case sym
        when :uuid, :string, :text, :integer, :float, :decimal, :boolean, :date, :datetime, :json, :jsonb
          sym.to_s
        else
          sym ? sym.to_s : 'string'
        end
      end

      # Convert writable value to descriptor hash
      def writable_descriptor(value)
        case value
        when Hash
          value
        when true
          { on: %i[create update] }
        when false
          { on: [] }
        when Proc
          { on: %i[create update] }
        else
          { on: [] }
        end
      end

      # Recursively collect schema and its associated resources
      #
      def collect_schema_with_associations(schema_class, schemas, seen_classes)
        return if seen_classes.include?(schema_class)

        seen_classes << schema_class

        # Get the schema metadata directly from resource class
        schema_info = describe_resource_class(schema_class)
        return unless schema_info

        # Add schema_class for later reference
        schema_info[:resource_class] = schema_class

        # Add member/collection action schemas
        add_action_schemas(schema_info, schema_class)

        schemas << schema_info

        # Recursively collect associated resources
        schema_info[:associations].each do |_assoc_name, assoc_info|
          next if assoc_info[:invalid]
          next unless assoc_info[:namespaces] && assoc_info[:name]

          # Try to find the associated resource class
          assoc_class = resolve_association_resource_class(assoc_info)
          next unless assoc_class

          collect_schema_with_associations(assoc_class, schemas, seen_classes)
        end
      end

      # Resolve association to resource class
      #
      def resolve_association_resource_class(assoc_info)
        namespaces = assoc_info[:namespaces]
        name = assoc_info[:name]

        # Build class name: e.g., Api::V1::AddressResource
        ns_prefix = namespaces.map(&:camelize).join('::')
        class_name = "#{ns_prefix}::#{name.to_s.camelize}Resource"

        class_name.constantize
      rescue NameError
        nil
      end

      # Add member/collection action schemas to schema info
      #
      def add_action_schemas(schema_info, schema_class)
        action_schemas = {}

        # Get resource name without "Resource" suffix
        resource_name = schema_class.name.demodulize.gsub(/Resource$/, '')

        # Member actions
        schema_class.instance_variable_get(:@member_actions)&.each do |action, schema|
          next unless schema # Skip state-only actions

          schema_name = "#{resource_name}#{action.to_s.camelize}ParamsSchema"
          action_schemas[schema_name] = generate_zod_from_schema(schema)
        end

        # Collection actions
        schema_class.instance_variable_get(:@collection_actions)&.each do |action, schema|
          next unless schema

          schema_name = "#{resource_name}#{action.to_s.camelize}ParamsSchema"
          action_schemas[schema_name] = generate_zod_from_schema(schema)
        end

        schema_info[:action_schemas] = action_schemas unless action_schemas.empty?
      end

      # Generate Zod schema from Ruby schema definition
      #
      def generate_zod_from_schema(schema)
        return 'z.void()' if schema.nil? || schema.empty?

        fields = schema.map do |field, definition|
          zod_type = convert_type_to_zod(definition[:type])
          required = definition[:required] ? '' : '.optional()'
          default = definition[:default] ? ".#{format_default(definition[:default])}" : ''

          "#{field}: #{zod_type}#{required}#{default}"
        end

        "z.object({ #{fields.join(', ')} })"
      end

      # Convert Ruby type to Zod type
      #
      def convert_type_to_zod(type)
        case type
        when :string
          'z.string()'
        when :integer
          'z.number().int()'
        when :boolean
          'z.boolean()'
        when :date, :datetime
          'z.string().datetime()'
        when :array
          'z.array(z.unknown())'
        when :hash
          'z.record(z.string(), z.unknown())'
        else
          'z.unknown()'
        end
      end

      # Format default value for Zod
      #
      def format_default(default)
        case default
        when String
          "default('#{default}')"
        when Integer, Float
          "default(#{default})"
        when TrueClass, FalseClass
          "default(#{default})"
        when Proc
          "default(() => #{default.call})"
        else
          "default(#{default.inspect})"
        end
      end

      # Validate that all schemas referenced in API exist
      #

      # Build endpoint definition for standard CRUD actions
      #
      def build_endpoint_definition_for_action(resource_name, action, metadata, schemas, key_transform, output_schemas,
                                               input_schemas, parent_path: [])
        schema = find_schema(schemas, resource_name.to_s.singularize)

        definition = {
          method: determine_http_method_for_action(action),
          path: build_path_for_action(resource_name, action, metadata)
        }

        # Add schemas based on action
        case action
        when :index
          if schema
            # Only create input schema if there are actual query params
            query_schema = schema_ref(schema, :query_schema)
            if query_schema != 'z.object({})' # Don't create empty schemas
              input_name = input_schema_name_for_endpoint(resource_name, action, parent_path: parent_path)
              input_schemas << { name: input_name, body: query_schema }
              definition[:input] = input_name
            end
          end
          if schema
            # Build output body (keeps wrap_response_schema - respects root_key!)
            base_response = "z.array(#{schema_ref(schema, :schema)})"
            output_body = wrap_response_schema(base_response, schema, true, key_transform)

            # Generate schema name and store
            output_name = output_schema_name(resource_name, action, parent_path: parent_path)
            output_schemas << { name: output_name, body: output_body }

            # Reference in definition
            definition[:output] = output_name
          end
        when :show
          if schema
            base_response = schema_ref(schema, :schema)
            output_body = wrap_response_schema(base_response, schema, false, key_transform)

            output_name = output_schema_name(resource_name, action, parent_path: parent_path)
            output_schemas << { name: output_name, body: output_body }
            definition[:output] = output_name
          end
        when :create
          if schema
            # Generate named input schema (respects root_key!)
            input_name = input_schema_name_for_endpoint(resource_name, action, parent_path: parent_path)
            input_body = wrap_body_schema(schema_ref(schema, :create_payload_schema), schema, key_transform)
            input_schemas << { name: input_name, body: input_body }
            definition[:input] = input_name

            base_response = schema_ref(schema, :schema)
            output_body = build_success_error_union(base_response, schema, key_transform)

            output_name = output_schema_name(resource_name, action, parent_path: parent_path)
            output_schemas << { name: output_name, body: output_body }
            definition[:output] = output_name
          end
        when :update
          if schema
            # Generate named input schema (respects root_key!)
            input_name = input_schema_name_for_endpoint(resource_name, action, parent_path: parent_path)
            input_body = wrap_body_schema(schema_ref(schema, :update_payload_schema), schema, key_transform)
            input_schemas << { name: input_name, body: input_body }
            definition[:input] = input_name

            base_response = schema_ref(schema, :schema)
            output_body = build_success_error_union(base_response, schema, key_transform)

            output_name = output_schema_name(resource_name, action, parent_path: parent_path)
            output_schemas << { name: output_name, body: output_body }
            definition[:output] = output_name
          end
        when :destroy
          meta_key = transform_key('meta', key_transform)
          ok_key = transform_key('ok', key_transform)
          errors_key = transform_key('errors', key_transform)
          success = "z.object({ #{ok_key}: z.literal(true), #{meta_key}: z.record(z.string(), z.unknown()) })"
          error = "z.object({ #{ok_key}: z.literal(false), #{errors_key}: ErrorSchema })"
          output_body = "z.discriminatedUnion('#{ok_key}', [#{success}, #{error}])"

          output_name = output_schema_name(resource_name, action, parent_path: parent_path)
          output_schemas << { name: output_name, body: output_body }
          definition[:output] = output_name
        end

        definition
      end

      # Build endpoint definition for member actions
      #
      def build_endpoint_definition_for_member_action(resource_name, action_name, action_info, metadata, schemas,
                                                      key_transform, output_schemas, input_schemas, parent_path: [])
        schema = find_schema(schemas, resource_name.to_s.singularize)

        definition = {
          method: action_info[:method].to_s.upcase,
          path: build_path_for_member_action(resource_name, action_name, metadata)
        }

        # Add Input class input if present
        definition[:input] = input_schema_reference(action_info[:input_class]) if action_info[:input_class]
        # Don't create empty input schemas for member actions without Input classes

        # Output
        if schema
          base_response = schema_ref(schema, :schema)
          output_body = build_success_error_union(base_response, schema, key_transform)
        else
          # Fallback
          meta_key = transform_key('meta', key_transform)
          ok_key = transform_key('ok', key_transform)
          errors_key = transform_key('errors', key_transform)
          success = "z.object({ #{ok_key}: z.literal(true), #{meta_key}: z.record(z.string(), z.unknown()) })"
          error = "z.object({ #{ok_key}: z.literal(false), #{errors_key}: ErrorSchema })"
          output_body = "z.discriminatedUnion('#{ok_key}', [#{success}, #{error}])"
        end

        output_name = output_schema_name(resource_name, action_name, parent_path: parent_path)
        output_schemas << { name: output_name, body: output_body }
        definition[:output] = output_name

        definition
      end

      # Build endpoint definition for collection actions
      #
      def build_endpoint_definition_for_collection_action(resource_name, action_name, action_info, metadata, schemas,
                                                          key_transform, output_schemas, input_schemas, parent_path: [])
        schema = find_schema(schemas, resource_name.to_s.singularize)

        definition = {
          method: action_info[:method].to_s.upcase,
          path: build_path_for_collection_action(resource_name, action_name, metadata)
        }

        # Add Input class input if present
        definition[:input] = input_schema_reference(action_info[:input_class]) if action_info[:input_class]
        # Don't create empty input schemas for collection actions without Input classes

        # Output
        if schema
          base_response = schema_ref(schema, :schema)
          output_body = build_success_error_union(base_response, schema, key_transform)
        else
          # Fallback
          meta_key = transform_key('meta', key_transform)
          ok_key = transform_key('ok', key_transform)
          errors_key = transform_key('errors', key_transform)
          success = "z.object({ #{ok_key}: z.literal(true), #{meta_key}: z.record(z.string(), z.unknown()) })"
          error = "z.object({ #{ok_key}: z.literal(false), #{errors_key}: ErrorSchema })"
          output_body = "z.discriminatedUnion('#{ok_key}', [#{success}, #{error}])"
        end

        output_name = output_schema_name(resource_name, action_name, parent_path: parent_path)
        output_schemas << { name: output_name, body: output_body }
        definition[:output] = output_name

        definition
      end

      # Build path for standard CRUD actions
      #
      def build_path_for_action(resource_name, action, metadata)
        base_path = build_base_path_for_resource(resource_name, metadata)

        case action
        when :index, :create
          base_path
        when :show, :update, :destroy
          "#{base_path}/:id"
        end
      end

      # Build path for member actions
      #
      def build_path_for_member_action(resource_name, action_name, metadata)
        base_path = build_base_path_for_resource(resource_name, metadata)
        "#{base_path}/:id/#{action_name}"
      end

      # Build path for collection actions
      #
      def build_path_for_collection_action(resource_name, action_name, metadata)
        base_path = build_base_path_for_resource(resource_name, metadata)
        "#{base_path}/#{action_name}"
      end

      # Build base path for a resource considering nesting
      #
      def build_base_path_for_resource(resource_name, metadata)
        if metadata[:parent]
          # This is a nested resource
          parent_path = build_base_path_for_parent(metadata[:parent])
          "#{parent_path}/:#{metadata[:parent].to_s.singularize}_id/#{resource_name}"
        else
          # Top-level resource
          "/#{resource_name}"
        end
      end

      # Build base path for parent resource (recursive)
      #
      def build_base_path_for_parent(parent_name)
        # For now, assume parent is top-level
        # In a full implementation, we'd need to track the full parent hierarchy
        "/#{parent_name}"
      end

      # Determine HTTP method for standard actions
      #
      def determine_http_method_for_action(action)
        case action
        when :index, :show
          'GET'
        when :create
          'POST'
        when :update
          'PATCH'
        when :destroy
          'DELETE'
        else
          'GET'
        end
      end

      # Parse path into segments identifying resources and parameters
      #
      def parse_path_segments(path)
        parts = path.split('/').reject(&:empty?)
        segments = []

        parts.each_with_index do |part, index|
          if part.start_with?(':')
            # Parameter segment (e.g., :id, :account_id)
            segments << { type: :param, name: part[1..] }
          else
            # Check if this is a member action (comes after :id parameter)
            is_member_action = index > 0 && parts[index - 1] == ':id'

            segments << if is_member_action
                          # This is a member action name, not a resource
                          { type: :action, name: part }
                        else
                          # Resource segment (e.g., accounts, services)
                          { type: :resource, name: part }
                        end
          end
        end

        segments
      end

      # Insert route into nested structure based on path segments
      #
      def insert_route_into_structure(structure, segments, route, schemas, key_transform)
        # Check if this is a member action (has :action segment)
        action_segment = segments.find { |s| s[:type] == :action }
        resource_segments = segments.select { |s| s[:type] == :resource }

        return if resource_segments.empty?

        # Navigate/create nested structure for all resources except the last
        current_level = structure
        resource_segments.each_with_index do |segment, index|
          resource_key = transform_key(segment[:name], key_transform)
          current_level[resource_key] ||= {}

          # If this is the last resource, place the action here
          if index == resource_segments.length - 1
            if action_segment
              # This is a member action - place directly under resource (same level as CRUD)
              action_key = transform_key(action_segment[:name], key_transform)
              action_name = action_segment[:name]
              current_level[resource_key][action_key] =
                build_endpoint_definition(route, schemas, key_transform, action_name: action_name)
            else
              # Standard CRUD action
              action_name = determine_action_name(route[:method], route[:path], route[:options])
              action_key = transform_key(action_name, key_transform)
              current_level[resource_key][action_key] = build_endpoint_definition(route, schemas, key_transform)
            end
          else
            # Otherwise, navigate deeper
            current_level = current_level[resource_key]
          end
        end
      end

      # Extract schema name from path (for schema matching)
      #
      def extract_schema_name_from_path(path)
        parts = path.split('/').reject(&:empty?)

        # Find the last resource part (before any member action)
        # For /accounts/:account_id/services/:id/archive, we want 'services'
        resource_parts = []
        parts.each_with_index do |part, index|
          next if part.start_with?(':')

          # Check if this is a member action (comes after :id)
          is_member_action = index > 0 && parts[index - 1] == ':id'
          resource_parts << part unless is_member_action
        end

        resource_parts.last
      end

      # Determine action name from HTTP method, path, and options
      #
      def determine_action_name(method, path, options = {})
        case method
        when :get
          if path.include?(':id')
            'find'
          elsif options[:singular]
            'get'
          else
            'query'
          end
        when :post
          'create'
        when :patch, :put
          # Check if this is a member action (has action name in path)
          if path.include?('/:id/') && path.split('/').last != ':id'
            # Extract action name from the end of path (e.g., /archive, /unarchive)
            path.split('/').last
          else
            'update'
          end
        when :delete
          'destroy'
        else
          method.to_s.downcase
        end
      end

      # Build endpoint definition with Zod schemas
      #
      def build_endpoint_definition(route, schemas, key_transform, action_name: nil)
        schema_name = extract_schema_name_from_path(route[:path])
        schema = find_schema(schemas, schema_name.singularize)

        definition = {
          method: route[:method].to_s.upcase,
          path: route[:path]
        }

        # Add metadata if available
        options = route[:options] || {}
        definition[:description] = options[:description] if options[:description]
        definition[:summary] = options[:summary] if options[:summary]
        definition[:deprecated] = options[:deprecated] if options[:deprecated]
        definition[:internal] = options[:internal] if options[:internal]

        # Add action params if this is a member/collection action with params
        if action_name && schema && schema[:action_schemas]
          resource_name = schema[:name].to_s.camelize.gsub(/Resource$/, '')
          action_schema_name = "#{resource_name}#{action_name.to_s.camelize}ParamsSchema"
          definition[:input] = action_schema_name if schema[:action_schemas][action_schema_name]
        end

        # Add schemas based on method and path
        case route[:method]
        when :get
          if route[:path].include?(':id')
            # Single resource (find)
            if schema
              base_response = schema_ref(schema, :schema)
              definition[:output] = wrap_response_schema(base_response, schema, false, key_transform)
            end
          elsif route[:options][:singular]
            # Singular resource (get) - no params parameter
            if schema
              base_response = schema_ref(schema, :schema)
              definition[:output] = wrap_response_schema(base_response, schema, false, key_transform)
            end
          else
            # Collection (query) - includes params parameter
            definition[:input] = schema_ref(schema, :query_schema) if schema
            if schema
              base_response = "z.array(#{schema_ref(schema, :schema)})"
              definition[:output] = wrap_response_schema(base_response, schema, true, key_transform)
            end
          end
        when :post
          # Create - use discriminated union for success/error
          if schema
            definition[:input] = wrap_body_schema(schema_ref(schema, :create_payload_schema), schema, key_transform)
            base_response = schema_ref(schema, :schema)
            definition[:output] = build_success_error_union(base_response, schema, key_transform)
          end
        when :patch, :put
          # Check if this is a member action (has action name in path)
          action_name = determine_action_name(route[:method], route[:path], route[:options])
          is_member_action = action_name != 'update'

          if is_member_action
            # Member action - only response, no body, use discriminated union
            if schema
              base_response = schema_ref(schema, :schema)
              definition[:output] = build_success_error_union(base_response, schema, key_transform)
            else
              # Fallback for member actions without schema
              meta_key = transform_key('meta', key_transform)
              ok_key = transform_key('ok', key_transform)
              errors_key = transform_key('errors', key_transform)
              success = "z.object({ #{ok_key}: z.literal(true), #{meta_key}: z.record(z.string(), z.unknown()) })"
              error = "z.object({ #{ok_key}: z.literal(false), #{errors_key}: ErrorSchema })"
              definition[:output] = "z.discriminatedUnion('#{ok_key}', [#{success}, #{error}])"
            end
          elsif schema
            # Standard update - body and response with discriminated union
            definition[:input] = wrap_body_schema(schema_ref(schema, :update_payload_schema), schema, key_transform)
            base_response = schema_ref(schema, :schema)
            definition[:output] = build_success_error_union(base_response, schema, key_transform)
          end
        when :delete
          # Destroy - return discriminated union with ok: true/false
          meta_key = transform_key('meta', key_transform)
          ok_key = transform_key('ok', key_transform)
          errors_key = transform_key('errors', key_transform)
          success = "z.object({ #{ok_key}: z.literal(true), #{meta_key}: z.record(z.string(), z.unknown()) })"
          error = "z.object({ #{ok_key}: z.literal(false), #{errors_key}: ErrorSchema })"
          definition[:output] = "z.discriminatedUnion('#{ok_key}', [#{success}, #{error}])"
        else
          # Custom actions (member/collection) - use discriminated union
          if schema
            base_response = schema_ref(schema, :schema)
            definition[:output] = build_success_error_union(base_response, schema, key_transform)
          else
            # Fallback for actions without schema
            meta_key = transform_key('meta', key_transform)
            ok_key = transform_key('ok', key_transform)
            errors_key = transform_key('errors', key_transform)
            success = "z.object({ #{ok_key}: z.literal(true), #{meta_key}: z.record(z.string(), z.unknown()) })"
            error = "z.object({ #{ok_key}: z.literal(false), #{errors_key}: ErrorSchema })"
            definition[:output] = "z.discriminatedUnion('#{ok_key}', [#{success}, #{error}])"
          end
        end

        definition
      end

      # Find schema by schema name
      #
      def find_schema(schemas, schema_name)
        return nil unless schema_name

        schemas.find { |s| s[:name].to_s == schema_name.to_s }
      end

      # Get schema reference string
      #
      def schema_ref(schema, type)
        return nil unless schema

        name = schema[:name].to_s.camelize

        case type
        when :schema
          "#{name}Schema"
        when :create_payload_schema
          "#{name}CreatePayloadSchema"
        when :update_payload_schema
          "#{name}UpdatePayloadSchema"
        when :query_schema
          "#{name}QueryParamsSchema"
        end
      end

      # Build MetaSchema with key transformation
      #
      def build_meta_schema(key_transform)
        page_key = transform_key('page', key_transform)
        per_page_key = transform_key('per_page', key_transform)
        total_key = transform_key('total', key_transform)

        <<~TYPESCRIPT.strip
          export const MetaSchema = z.object({
            #{page_key}: z.number(),
            #{per_page_key}: z.number(),
            #{total_key}: z.number()
          }).passthrough();
        TYPESCRIPT
      end

      # Build error schema for structured errors
      #
      # New format with code, path, pointer, detail, and optional metadata
      #
      def build_error_schema(_key_transform)
        <<~TYPESCRIPT.strip
          export const ErrorItemSchema = z.object({
            code: z.string(),
            path: z.array(z.string()),
            pointer: z.string(),
            detail: z.string(),
            options: z.record(z.string(), z.unknown()).optional()
          });

          export const ErrorSchema = z.array(ErrorItemSchema);
        TYPESCRIPT
      end

      # Build helper functions and utility types for builders
      #
      def build_builder_helpers
        <<~TYPESCRIPT.strip
          type Pretty<T> = { [K in keyof T]: T[K] } & {};

          type RequiredExcept<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;

          function uuid(): string {
            return crypto.randomUUID();
          }

          function datetime(): string {
            return new Date().toISOString();
          }

          function date(): string {
            return new Date().toISOString().split('T')[0];
          }
        TYPESCRIPT
      end

      # Build discriminated union for success/error responses (non-GET endpoints)
      #
      def build_success_error_union(schema_ref, schema_metadata, key_transform)
        return 'z.void()' unless schema_metadata

        resource_class = schema_metadata[:resource_class]
        return 'z.void()' unless resource_class

        # Get root key from resource class (always singular for create/update)
        type = resource_class.root_key.singular
        wrapper_key = transform_key(type, key_transform)

        # Transform keys
        ok_key = transform_key('ok', key_transform)
        meta_key = transform_key('meta', key_transform)
        errors_key = transform_key('errors', key_transform)

        # Build success and error schemas
        success = "z.object({ #{ok_key}: z.literal(true), #{wrapper_key}: #{schema_ref}, #{meta_key}: z.record(z.string(), z.unknown()) })"
        error = "z.object({ #{ok_key}: z.literal(false), #{errors_key}: ErrorSchema })"

        # Return discriminated union
        "z.discriminatedUnion('#{ok_key}', [#{success}, #{error}])"
      end

      # Wrap response schema with root_key and metadata
      #
      def wrap_response_schema(schema_ref, schema_metadata, is_collection, key_transform)
        return schema_ref unless schema_metadata

        resource_class = schema_metadata[:resource_class]
        return schema_ref unless resource_class

        # Get root key from resource class (plural for collections, singular for single)
        root_key = resource_class.root_key
        type = is_collection ? root_key.plural : root_key.singular
        wrapper_key = transform_key(type, key_transform)

        # Generate wrapped schema with appropriate meta type
        # Collections use MetaSchema (with pagination), singles use flexible record
        ok_key = transform_key('ok', key_transform)
        meta_key = transform_key('meta', key_transform)
        meta_schema = is_collection ? 'MetaSchema' : 'z.record(z.string(), z.unknown())'

        "z.object({ #{ok_key}: z.literal(true), #{wrapper_key}: #{schema_ref}, #{meta_key}: #{meta_schema} })"
      end

      # Wrap body schema with root_key (for create/update requests)
      #
      def wrap_body_schema(schema_ref, schema_metadata, key_transform)
        return schema_ref unless schema_metadata

        resource_class = schema_metadata[:resource_class]
        return schema_ref unless resource_class

        # Get root key from resource class (always singular for request bodies)
        type = resource_class.root_key.singular
        wrapper_key = transform_key(type, key_transform)

        "z.object({ #{wrapper_key}: #{schema_ref} })"
      end

      # Build complete TypeScript document
      #
      def build_typescript_document(contract, schemas, key_transform, builders: false, enum_definitions: '',
                                    input_schemas: [], endpoint_input_schemas: [], output_schemas: [])
        parts = []

        # Imports
        parts << "import { z } from 'zod';"

        # Common query schemas
        parts << Zod.send(:build_common_schemas, key_transform)

        # Meta schema
        parts << build_meta_schema(key_transform)

        # Error schema
        parts << build_error_schema(key_transform)

        # Enum schemas
        parts << enum_definitions unless enum_definitions.empty?

        # Schema schemas (without type declarations)
        parts << schemas.map { |s| format_schema_schemas_without_types(s) }.join("\n\n")

        # Input schemas (from Input classes)
        parts << input_schemas.join("\n\n") unless input_schemas.empty?

        # Endpoint Input schemas (NEW)
        parts << endpoint_input_schemas.join("\n\n") unless endpoint_input_schemas.empty?

        # Output schemas (NEW)
        parts << output_schemas.join("\n\n") unless output_schemas.empty?

        # All type declarations together (with blank line between resources)
        parts << schemas.map { |s| format_type_declarations(s) }.join("\n\n")

        # Builders (if enabled)
        if builders
          parts << build_builder_helpers
          parts << build_all_builders(schemas, key_transform)
        end

        # Contract object
        parts << format_contract_object(contract, key_transform)
        parts << 'export type Contract = typeof contract;'

        # Join all parts with exactly one blank line between them
        parts.compact.reject(&:empty?).join("\n\n")
      end

      # Collect enum schemas from schemas
      #
      def collect_enum_schemas(schemas, key_transform)
        enums = {}

        schemas.each do |schema|
          next unless schema[:name] # Skip if no name
          next unless schema[:attributes] # Skip if no attributes

          schema[:attributes].each do |attr_name, attr_info|
            next unless attr_info[:enum]

            enum_name = "#{schema[:name].to_s.camelize}#{attr_name.to_s.camelize}"
            enums[enum_name] = {
              values: attr_info[:enum],
              resource_name: schema[:name],
              attr_name: attr_name
            }
          end
        end

        enum_schemas = enums.map do |name, info|
          values_str = info[:values].map { |v| "'#{v}'" }.join(', ')
          "export const #{name}Schema = z.enum([#{values_str}]);"
        end.join("\n\n")

        enum_filter_schemas = enums.map do |name, _info|
          format_enum_filter_schema("#{name}Schema", key_transform)
        end.join("\n\n")

        [enum_schemas, enum_filter_schemas].reject(&:empty?).join("\n\n")
      end

      # Format enum filter schema
      #
      def format_enum_filter_schema(enum_name, key_transform)
        base_name = enum_name.gsub(/Schema$/, '')
        equal_key = transform_key('equal', key_transform)
        not_equal_key = transform_key('not_equal', key_transform)

        <<~TYPESCRIPT.strip
          export const #{base_name}FilterSchema = z.union([
            #{enum_name},
            z.object({
              #{equal_key}: #{enum_name}.optional(),
              #{not_equal_key}: #{enum_name}.optional(),
              in: z.array(#{enum_name}).optional()
            })
          ]);
        TYPESCRIPT
      end

      # Format schema schemas WITHOUT type declarations
      #
      def format_schema_schemas_without_types(schema)
        parts = []

        # Main schemas
        parts << schema[:schema]
        parts << ''
        parts << schema[:create_payload_schema]
        parts << ''
        parts << schema[:update_payload_schema]
        parts << ''
        parts << schema[:query_schema]

        # Action schemas (without types)
        if schema[:action_schemas]&.any?
          parts << ''
          schema[:action_schemas].each do |schema_name, zod_schema|
            parts << "export const #{schema_name} = #{zod_schema};"
          end
        end

        parts.join("\n")
      end

      # Format type declarations for a schema
      #
      def format_type_declarations(schema)
        name = schema[:name].to_s.camelize
        types = []

        # Main types
        types << "export type #{name} = z.infer<typeof #{name}Schema>;"
        types << "export type #{name}CreatePayload = z.infer<typeof #{name}CreatePayloadSchema>;"
        types << "export type #{name}UpdatePayload = z.infer<typeof #{name}UpdatePayloadSchema>;"
        types << "export type #{name}QueryParams = z.infer<typeof #{name}QueryParamsSchema>;"

        # Action types
        if schema[:action_schemas]&.any?
          schema[:action_schemas].each_key do |schema_name|
            type_name = schema_name.gsub(/Schema$/, '')
            types << "export type #{type_name} = z.infer<typeof #{schema_name}>;"
          end
        end

        types.join("\n")
      end

      # Format contract object
      #
      def format_contract_object(contract, key_transform)
        "export const contract = #{format_contract_hash(contract, 1, key_transform)} as const;"
      end

      # Format contract hash recursively
      #
      def format_contract_hash(hash, indent_level, key_transform)
        return '{}' if hash.empty?

        indent = '  ' * indent_level
        inner_indent = '  ' * (indent_level + 1)

        lines = hash.map do |key, value|
          formatted_key = key # Already transformed

          if value.is_a?(Hash)
            if value[:method]
              # This is an endpoint definition
              "#{inner_indent}#{formatted_key}: #{format_endpoint(value, indent_level + 1)}"
            else
              # This is a nested resource
              "#{inner_indent}#{formatted_key}: #{format_contract_hash(value, indent_level + 1, key_transform)}"
            end
          else
            "#{inner_indent}#{formatted_key}: #{value.inspect}"
          end
        end

        "{\n#{lines.join(",\n")}\n#{indent}}"
      end

      # Format endpoint definition
      #
      def format_endpoint(endpoint, indent_level)
        indent = '  ' * indent_level
        inner_indent = '  ' * (indent_level + 1)

        lines = []
        lines << "#{inner_indent}method: '#{endpoint[:method]}'"
        lines << "#{inner_indent}path: '#{endpoint[:path]}'"
        lines << "#{inner_indent}description: '#{endpoint[:description]}'" if endpoint[:description]
        lines << "#{inner_indent}input: #{endpoint[:input]}" if endpoint[:input]
        lines << "#{inner_indent}output: #{endpoint[:output]}" if endpoint[:output]

        "{\n#{lines.join(",\n")}\n#{indent}}"
      end

      # Generate Zod schema from Input class
      #
      def generate_input_schema(input_class, key_transform)
        return nil unless input_class

        # Get param definitions from Input class
        param_definitions = input_class.param_definitions
        return nil if param_definitions.empty?

        # Generate Zod schema from param definitions
        generate_zod_schema_from_params(param_definitions, key_transform)
      end

      # Generate Zod schema from param definitions
      #
      def generate_zod_schema_from_params(param_definitions, key_transform)
        zod_fields = []

        param_definitions.each do |name, definition|
          field_name = transform_key(name.to_s, key_transform)
          zod_type = map_param_type_to_zod(definition[:type], definition, key_transform)

          # Add required/optional
          zod_fields << if definition[:required]
                          "#{field_name}: #{zod_type}"
                        else
                          "#{field_name}: #{zod_type}.optional()"
                        end
        end

        "z.object({ #{zod_fields.join(', ')} })"
      end

      # Map param type to Zod type
      #
      def map_param_type_to_zod(type, definition, key_transform)
        case type
        when :string
          zod = 'z.string()'
          zod += ".enum([#{definition[:enum].map { |e| "'#{e}'" }.join(', ')}])" if definition[:enum]
          zod
        when :integer
          'z.number().int()'
        when :decimal, :float
          'z.number()'
        when :boolean
          'z.boolean()'
        when :date
          'z.string().date()'
        when :datetime
          'z.string().datetime()'
        when :uuid
          'z.string().uuid()'
        when :array
          if definition[:of]
            element_type = map_param_type_to_zod(definition[:of], {}, key_transform)
            "z.array(#{element_type})"
          elsif definition[:nested_class]
            nested_schema = generate_zod_schema_from_params(definition[:nested_class].param_definitions,
                                                            key_transform)
            "z.array(#{nested_schema})"
          else
            'z.array(z.unknown())'
          end
        when :object
          if definition[:nested_class]
            generate_zod_schema_from_params(definition[:nested_class].param_definitions, key_transform)
          else
            'z.record(z.string(), z.unknown())'
          end
        when :hash, :json
          'z.record(z.string(), z.unknown())'
        else
          'z.unknown()'
        end
      end

      # Generate Input schema name from resource and action
      # For nested resources, includes parent resource name to avoid conflicts
      def input_schema_name_for_endpoint(resource_name, action_name, parent_path: [])
        parts = []

        # Add all parents from the path (for deep nesting like AccountSiteAssignmentAgreement)
        if parent_path.any?
          parent_path.compact.each do |parent|
            next if parent.nil? || parent.to_s.empty?

            parts << parent.to_s.singularize.camelize
          end
        end

        parts << resource_name.to_s.singularize.camelize if resource_name.present?
        parts << action_name.to_s.camelize if action_name.present?
        parts << 'Input'
        parts.compact.join
      end

      # Examples:
      # input_schema_name_for_endpoint(:accounts, :index) → "AccountIndexInput"
      # input_schema_name_for_endpoint(:sites, :index, parent_path: [:accounts]) → "AccountSiteIndexInput"
      # input_schema_name_for_endpoint(:services, :archive, parent_path: [:accounts]) → "AccountServiceArchiveInput"
      # input_schema_name_for_endpoint(:agreements, :index, parent_path: [:accounts, :sites, :assignments]) → "AccountSiteAssignmentAgreementIndexInput"

      # Generate Output schema name from resource and action
      # For nested resources, includes parent resource name to avoid conflicts
      def output_schema_name(resource_name, action_name, parent_resource_name: nil, parent_path: [])
        parts = []

        # Add all parents from the path (for deep nesting like AccountSiteAssignmentAgreement)
        if parent_path.any?
          parent_path.compact.each do |parent|
            next if parent.nil? || parent.to_s.empty?

            parts << parent.to_s.singularize.camelize
          end
        elsif parent_resource_name
          # Fallback to single parent for backward compatibility
          parts << parent_resource_name.to_s.singularize.camelize
        end

        parts << resource_name.to_s.singularize.camelize if resource_name.present?
        parts << action_name.to_s.camelize if action_name.present?
        parts << 'Output'
        parts.compact.join
      end

      # Examples:
      # output_schema_name(:accounts, :index) → "AccountIndexOutput"
      # output_schema_name(:sites, :index, parent_path: [:accounts]) → "AccountSiteIndexOutput"
      # output_schema_name(:services, :archive, parent_path: [:accounts]) → "AccountServiceArchiveOutput"
      # output_schema_name(:agreements, :index, parent_path: [:accounts, :sites, :assignments]) → "AccountSiteAssignmentAgreementIndexOutput"

      # Generate Output schemas section
      def generate_output_schemas(output_schemas)
        # Remove duplicates by name
        output_schemas.uniq { |s| s[:name] }.map do |schema|
          "export const #{schema[:name]} = #{schema[:body]};"
        end
      end

      # Generate Input schemas for endpoints section
      def generate_input_schemas_for_endpoints(input_schemas)
        # Remove duplicates by name
        input_schemas.uniq { |s| s[:name] }.map do |schema|
          "export const #{schema[:name]} = #{schema[:body]};"
        end
      end

      # Generate all builder functions
      #
      def build_all_builders(schemas, key_transform)
        schemas.map { |schema| build_schema_builder(schema, key_transform) }.compact.join("\n\n")
      end

      # Generate builder functions for a schema (main schema + payload schemas)
      #
      def build_schema_builder(schema, key_transform)
        name = schema[:name].to_s.camelize
        resource_class = schema[:resource_class]

        return nil unless resource_class

        builders = []

        # 1. Main schema builder (for full schema)
        builders << build_single_builder(
          builder_name: "build#{name}",
          type_name: name,
          schema: schema,
          key_transform: key_transform,
          context: :full
        )

        # 2. Create payload builder
        builders << build_single_builder(
          builder_name: "build#{name}CreatePayload",
          type_name: "#{name}CreatePayload",
          schema: schema,
          key_transform: key_transform,
          context: :create
        )

        # 3. Update payload builder
        builders << build_single_builder(
          builder_name: "build#{name}UpdatePayload",
          type_name: "#{name}UpdatePayload",
          schema: schema,
          key_transform: key_transform,
          context: :update
        )

        builders.compact.join("\n\n")
      end

      # Generate a single builder function
      #
      def build_single_builder(builder_name:, type_name:, schema:, key_transform:, context:)
        resource_class = schema[:resource_class]
        return '' unless resource_class

        # Get attributes with/without defaults
        attrs_with_defaults, attrs_without_defaults = partition_by_defaults(schema, context, key_transform)

        # Build parameter type and data type name
        data_type_name = "#{builder_name.sub(/^build/, 'Build')}Data"

        if attrs_without_defaults.empty?
          # All have defaults - overrides are fully optional
          inline_type = "Partial<#{type_name}>"
          param_type = "data?: #{data_type_name}"
        else
          # Some fields required (no defaults)
          default_keys = attrs_with_defaults.map { |attr| attr[:transformed_key] }

          inline_type = if default_keys.empty?
                          # No defaults at all - everything required
                          type_name
                        else
                          # Some have defaults, some don't
                          omit_keys = default_keys.map { |k| "'#{k}'" }.join(' | ')
                          pick_keys = default_keys.map { |k| "'#{k}'" }.join(' | ')
                          "Omit<#{type_name}, #{omit_keys}> & Partial<Pick<#{type_name}, #{pick_keys}>>"
                        end
          param_type = "data: #{data_type_name}"
        end
        data_var = 'data'

        # Build defaults (only for attributes with DB defaults)
        defaults = build_defaults_only(attrs_with_defaults)

        # Generate type declaration + function
        type_declaration = "export type #{data_type_name} = Pretty<#{inline_type}>;"

        function_declaration = <<~TYPESCRIPT.strip
          export function #{builder_name}(#{param_type}): #{type_name} {
            return {
          #{defaults}    ...#{data_var}
            };
          }
        TYPESCRIPT

        "#{type_declaration}\n\n#{function_declaration}"
      end

      # Partition attributes by whether they have database defaults
      #
      def partition_by_defaults(schema, context, key_transform)
        resource_class = schema[:resource_class]
        return [[], []] unless resource_class

        resource_info = describe_resource_class(resource_class)
        model_class = resource_class.model_class
        attributes = resource_info[:attributes] || {}

        # Filter attributes based on context (create/update/full)
        filtered_attrs = filter_attributes_by_context(attributes, context)

        with_defaults = []
        without_defaults = []

        filtered_attrs.each do |attr_name, attr_info|
          # Check if attribute has DB default
          column = model_class.columns_hash[attr_name.to_s]

          # Transform key for TypeScript
          transformed_key = transform_key(attr_name.to_s, key_transform)

          attr_data = {
            name: attr_name,
            transformed_key: transformed_key,
            info: attr_info,
            column: column
          }

          # Always include id, createdAt, updatedAt as defaults
          if %w[id created_at updated_at].include?(attr_name.to_s)
            with_defaults << attr_data
          elsif column&.default.present?
            # Has DB default
            with_defaults << attr_data
          elsif column&.null && context != :full
            # Nullable columns in payloads (optional) count as having defaults
            with_defaults << attr_data
          else
            # Required, no default
            without_defaults << attr_data
          end
        end

        [with_defaults, without_defaults]
      end

      # Filter attributes based on context (full/create/update)
      #
      def filter_attributes_by_context(attributes, context)
        case context
        when :full
          # Full schema - all attributes
          attributes
        when :create
          # Create payload - only writable on create
          attributes.select do |_name, info|
            writable = info[:writable]
            [true, :on_create].include?(writable)
          end
        when :update
          # Update payload - only writable on update (all optional)
          attributes.select do |_name, info|
            writable = info[:writable]
            [true, :on_update].include?(writable)
          end
        else
          attributes
        end
      end

      # Build defaults only for attributes that have them
      #
      def build_defaults_only(attrs_with_defaults)
        return '' if attrs_with_defaults.empty?

        defaults = attrs_with_defaults.map do |attr|
          attr_name = attr[:name]
          transformed_key = attr[:transformed_key]
          column = attr[:column]

          # Handle special Rails fields
          case attr_name.to_s
          when 'id'
            "      #{transformed_key}: uuid(),"
          when 'created_at', 'updated_at'
            "      #{transformed_key}: datetime(),"
          else
            # Get default from DB if available
            if column&.default.present?
              default_value = format_database_default(column.default, column.type)
              "      #{transformed_key}: #{default_value},"
            end
          end
        end.compact

        return '' if defaults.empty?

        "#{defaults.join("\n")}\n"
      end

      # Format database default value for TypeScript
      #
      def format_database_default(default_value, column_type)
        case column_type
        when :string, :text
          "'#{default_value}'"
        when :integer, :decimal, :float
          default_value.to_s
        when :boolean
          default_value.to_s
        when :datetime, :date, :time
          # If DB has NOW() or CURRENT_TIMESTAMP, use JS equivalent
          if default_value.to_s.match?(/now|current/i)
            'datetime()'
          else
            "'#{default_value}'"
          end
        when :uuid
          'uuid()'
        else
          "'#{default_value}'"
        end
      end

      # Validate schemas from APIInspector
      #
      def validate_api_schemas_from_inspector(resources, path)
        resources.each do |resource|
          class_name = resource[:class_name]
          raise APIError, "Resource class not found: #{class_name} (path: #{path})" unless class_exists?(class_name)
        end
      end

      # Generate input schemas from APIInspector inputs
      #
      def generate_input_schemas_from_inspector(inputs, key_transform)
        inputs.map do |input|
          {
            class_name: input[:class_name],
            name: input[:name],
            params: input[:params]
          }
        end
      end

      # Build contract structure from routes metadata
      #
      def build_contract_structure_from_routes(routes, zod_schemas, key_transform)
        structure = {}
        output_schemas = []
        input_schemas = []

        # Process each route
        routes.each do |name, route_metadata|
          process_route_metadata(name, route_metadata, structure, zod_schemas, key_transform, output_schemas,
                                 input_schemas)
        end

        { contract: structure, output_schemas: output_schemas, input_schemas: input_schemas }
      end

      # Process a single route and its nested routes
      #
      def process_route_metadata(name, route_metadata, structure, zod_schemas, key_transform, output_schemas,
                                 input_schemas, parent_path: [])
        resource_key = transform_key(name.to_s, key_transform)
        current_level = structure

        # Navigate to the correct level in the structure
        parent_path.each do |parent_name|
          parent_key = transform_key(parent_name.to_s, key_transform)
          current_level[parent_key] ||= {}
          current_level = current_level[parent_key]
        end

        # Add CRUD actions
        (route_metadata[:actions] || []).each do |action|
          action_key = transform_key(action.to_s, key_transform)
          current_level[resource_key] ||= {}
          current_level[resource_key][action_key] = build_endpoint_definition_for_route_action(
            name, action, route_metadata, zod_schemas, key_transform, output_schemas, input_schemas, parent_path: parent_path
          )
        end

        # Add member actions
        (route_metadata[:members] || {}).each do |action_name, action_info|
          action_key = transform_key(action_name.to_s, key_transform)
          current_level[resource_key] ||= {}
          current_level[resource_key][action_key] = build_endpoint_definition_for_member_action(
            name, action_name, action_info, route_metadata, zod_schemas, key_transform, output_schemas, input_schemas, parent_path: parent_path
          )
        end

        # Add collection actions
        (route_metadata[:collections] || {}).each do |action_name, action_info|
          action_key = transform_key(action_name.to_s, key_transform)
          current_level[resource_key] ||= {}
          current_level[resource_key][action_key] = build_endpoint_definition_for_collection_action(
            name, action_name, action_info, route_metadata, zod_schemas, key_transform, output_schemas, input_schemas, parent_path: parent_path
          )
        end

        # Recursively process nested routes
        (route_metadata[:routes] || {}).each do |nested_name, nested_route_metadata|
          process_route_metadata(
            nested_name,
            nested_route_metadata,
            structure,
            zod_schemas,
            key_transform,
            output_schemas,
            input_schemas,
            parent_path: parent_path + [name].compact
          )
        end
      end

      # Check if a class exists
      #
      def class_exists?(class_name)
        class_name.constantize
        true
      rescue NameError
        false
      end

      # Generate Input schema reference for endpoint
      #
      def input_schema_reference(input_class)
        # Api::V1::ServiceArchiveInput -> ServiceArchiveInputSchema
        class_name = input_class.name.split('::').last
        "#{class_name}Schema"
      end

      # Build endpoint definition for standard CRUD actions using APIInspector routes
      #
      def build_endpoint_definition_for_route_action(resource_name, action, route_metadata, zod_schemas, key_transform,
                                                     output_schemas, input_schemas, parent_path: [])
        definition = {
          method: determine_http_method_for_action(action),
          path: build_path_for_route_action(resource_name, action, route_metadata)
        }

        # Try to find schema for this resource
        schema = find_schema(zod_schemas, resource_name.to_s.singularize)

        if schema
          # Add input schema for create, update and index actions
          case action
          when :index
            # Only create input schema if there are actual query params
            query_schema = schema_ref(schema, :query_schema)
            if query_schema != 'z.object({})' # Don't create empty schemas
              input_name = input_schema_name_for_endpoint(resource_name, action, parent_path: parent_path)
              input_schemas << { name: input_name, body: query_schema }
              definition[:input] = input_name
            end
          when :create
            input_name = input_schema_name_for_endpoint(resource_name, action, parent_path: parent_path)
            input_body = wrap_body_schema(schema_ref(schema, :create_payload_schema), schema, key_transform)
            input_schemas << { name: input_name, body: input_body }
            definition[:input] = input_name
          when :update
            input_name = input_schema_name_for_endpoint(resource_name, action, parent_path: parent_path)
            input_body = wrap_body_schema(schema_ref(schema, :update_payload_schema), schema, key_transform)
            input_schemas << { name: input_name, body: input_body }
            definition[:input] = input_name
          end

          # Add output schema for all actions
          case action
          when :index
            base_response = "z.array(#{schema_ref(schema, :schema)})"
            output_body = wrap_response_schema(base_response, schema, true, key_transform)
            output_name = output_schema_name(resource_name, action, parent_path: parent_path)
            output_schemas << { name: output_name, body: output_body }
            definition[:output] = output_name
          when :show
            base_response = schema_ref(schema, :schema)
            output_body = wrap_response_schema(base_response, schema, false, key_transform)
            output_name = output_schema_name(resource_name, action, parent_path: parent_path)
            output_schemas << { name: output_name, body: output_body }
            definition[:output] = output_name
          when :create, :update
            base_response = schema_ref(schema, :schema)
            output_body = build_success_error_union(base_response, schema, key_transform)
            output_name = output_schema_name(resource_name, action, parent_path: parent_path)
            output_schemas << { name: output_name, body: output_body }
            definition[:output] = output_name
          when :destroy
            meta_key = transform_key('meta', key_transform)
            ok_key = transform_key('ok', key_transform)
            errors_key = transform_key('errors', key_transform)
            success = "z.object({ #{ok_key}: z.literal(true), #{meta_key}: z.record(z.string(), z.unknown()) })"
            error = "z.object({ #{ok_key}: z.literal(false), #{errors_key}: ErrorSchema })"
            output_body = "z.discriminatedUnion('#{ok_key}', [#{success}, #{error}])"
            output_name = output_schema_name(resource_name, action, parent_path: parent_path)
            output_schemas << { name: output_name, body: output_body }
            definition[:output] = output_name
          end
        end

        definition
      end

      # Build path for route action
      #
      def build_path_for_route_action(resource_name, action, route_metadata)
        case action
        when :index
          "/#{resource_name}"
        when :show
          "/#{resource_name}/:id"
        when :create
          "/#{resource_name}"
        when :update
          "/#{resource_name}/:id"
        when :destroy
          "/#{resource_name}/:id"
        else
          "/#{resource_name}"
        end
      end
    end
  end
end
