# frozen_string_literal: true

module Apiwork
  module Generation
    class OpenAPI < Base
      generator_name :openapi
      content_type 'application/json'

      def self.file_extension
        '.json'
      end

      def initialize(path, key_transform: :camelize_lower, **options)
        @path = path
        @key_transform = key_transform
        @options = options

        @documentation = Inspector.documentation(path: path)
        @routes = Inspector.routes(path: path)
        @resources = Inspector.resources(path: path)
      end

      def needs_resources?
        true
      end

      def needs_routes?
        true
      end

      def needs_documentation?
        true
      end

      def generate
        {
          openapi: '3.1.0',
          info: build_info,
          servers: build_servers,
          paths: build_paths,
          components: build_components,
          tags: build_tags
        }.compact
      end

      private

      def determine_wrapper_key(resource_name, metadata, is_collection)
        resource_class = metadata[:resource_class]

        if resource_class
          root_key = resource_class.root_key
          type = is_collection ? root_key.plural : root_key.singular
        else
          # Fallback when no resource class
          type = resource_name.to_s.singularize
          type = type.pluralize if is_collection
        end

        transform_key(type)
      end

      def build_info
        api_doc = @documentation[:api] || {}

        {
          title: api_doc[:title] || "#{@path} API",
          version: api_doc[:version] || '1.0.0',
          description: api_doc[:description],
          termsOfService: api_doc[:terms_of_service],
          contact: build_contact(api_doc[:contact]),
          license: build_license(api_doc[:license])
        }.compact
      end

      def build_servers
        api_doc = @documentation[:api] || {}
        servers = api_doc[:servers] || []

        return nil if servers.empty?

        servers.map do |server|
          {
            url: server[:url],
            description: server[:description]
          }.compact
        end
      end

      def build_paths
        paths = {}

        # Get API metadata to access nested resources
        api = Apiwork::API.find(@path)
        return paths unless api

        # Build paths recursively for all resources
        build_resource_paths(paths, api.metadata.resources, [])

        paths
      end

      def build_resource_paths(paths, resources, parent_path)
        resources.each do |resource_name, metadata|
          # Build current resource path
          current_path = parent_path + [resource_name]
          path_string = "#{@path}/#{current_path.join('/')}"

          resource_doc = metadata[:doc] || {}
          actions_doc = resource_doc[:actions] || {}

          # Build standard CRUD paths
          build_crud_paths(paths, path_string, metadata, actions_doc, resource_doc, resource_name)

          # Build member action paths
          if metadata[:members]&.any?
            metadata[:members].each do |action, action_metadata|
              member_path = "#{path_string}/{id}/#{action}"
              method = (action_metadata[:method] || :patch).to_s.downcase

              paths[member_path] ||= {}
              paths[member_path][method] = build_operation(
                action: action,
                action_doc: actions_doc[action],
                resource_doc: resource_doc,
                is_member: true,
                resource_name: resource_name,
                metadata: metadata
              )
            end
          end

          # Build collection action paths
          if metadata[:collections]&.any?
            metadata[:collections].each do |action, action_metadata|
              collection_path = "#{path_string}/#{action}"
              method = (action_metadata[:method] || :get).to_s.downcase

              paths[collection_path] ||= {}
              paths[collection_path][method] = build_operation(
                action: action,
                action_doc: actions_doc[action],
                resource_doc: resource_doc,
                is_collection: true,
                resource_name: resource_name,
                metadata: metadata
              )
            end
          end

          # Recursively build nested resource paths
          next unless metadata[:resources]&.any?

          parent_resource_id = metadata[:singular] ? 'id' : "#{resource_name.to_s.singularize}_id"
          nested_parent_path = current_path[0..-2] + [current_path[-1], "{#{parent_resource_id}}"]
          build_resource_paths(paths, metadata[:resources], nested_parent_path)
        end
      end

      def build_crud_paths(paths, base_path, metadata, actions_doc, resource_doc, resource_name)
        actions = metadata[:actions] || []

        # Index (GET /resource)
        if actions.include?(:index)
          paths[base_path] ||= {}
          paths[base_path][:get] = build_operation(
            action: :index,
            action_doc: actions_doc[:index],
            resource_doc: resource_doc,
            resource_name: resource_name,
            metadata: metadata
          )
        end

        # Create (POST /resource)
        if actions.include?(:create)
          paths[base_path] ||= {}
          paths[base_path][:post] = build_operation(
            action: :create,
            action_doc: actions_doc[:create],
            resource_doc: resource_doc,
            resource_name: resource_name,
            metadata: metadata
          )
        end

        # Show (GET /resource/:id)
        if actions.include?(:show)
          paths["#{base_path}/{id}"] ||= {}
          paths["#{base_path}/{id}"][:get] = build_operation(
            action: :show,
            action_doc: actions_doc[:show],
            resource_doc: resource_doc,
            resource_name: resource_name,
            metadata: metadata
          )
        end

        # Update (PATCH /resource/:id)
        if actions.include?(:update)
          paths["#{base_path}/{id}"] ||= {}
          paths["#{base_path}/{id}"][:patch] = build_operation(
            action: :update,
            action_doc: actions_doc[:update],
            resource_doc: resource_doc,
            resource_name: resource_name,
            metadata: metadata
          )
        end

        # Destroy (DELETE /resource/:id)
        return unless actions.include?(:destroy)

        paths["#{base_path}/{id}"] ||= {}
        paths["#{base_path}/{id}"][:delete] = build_operation(
          action: :destroy,
          action_doc: actions_doc[:destroy],
          resource_doc: resource_doc,
          resource_name: resource_name,
          metadata: metadata
        )
      end

      def build_operation(action:, action_doc:, resource_doc:, is_member: false, is_collection: false,
                          resource_name: nil, metadata: nil)
        # NOTE: is_member and is_collection are kept for future use
        _ = is_member
        _ = is_collection
        operation = {
          summary: action_doc&.dig(:summary) || "#{action.to_s.humanize} #{resource_doc[:summary] || 'resource'}",
          description: action_doc&.dig(:description),
          tags: build_tags_for_operation(action_doc, resource_doc),
          deprecated: action_doc&.dig(:deprecated) || false
        }.compact

        # Add request body for POST/PATCH operations
        if %i[create update].include?(action) || action.to_s.match?(/^(post|patch|put)$/i)
          operation[:requestBody] = build_request_body(resource_doc, resource_name, action, metadata)
        end

        # Add responses
        operation[:responses] = build_responses(action, resource_doc, resource_name, metadata)

        operation
      end

      def build_request_body(resource_doc, resource_name, action, metadata)
        # Try to resolve contract for this action
        controller_class = metadata[:controller_class] if metadata
        contract_class = nil

        contract_class = Contract::Resolver.resolve(controller_class, action) if controller_class

        # Build schema from contract or fallback to generic object
        schema = if contract_class&.input_definition
                   build_openapi_from_definition(contract_class.input_definition)
                 else
                   {
                     type: 'object',
                     properties: build_schema_properties(resource_doc)
                   }
                 end

        {
          required: true,
          content: {
            'application/json' => {
              schema: schema
            }
          }
        }
      end

      def build_responses(action, resource_doc, resource_name = nil, metadata = nil)
        responses = {
          '200' => {
            description: 'Successful response',
            content: {
              'application/json' => {
                schema: build_response_schema(resource_doc, resource_name, action, metadata)
              }
            }
          }
        }

        # Add 422 error response for mutations (create, update, destroy, member actions)
        if %i[create update
              destroy].include?(action) || action.to_s.match?(/^(post|patch|put|delete)/i) || action.to_s.match?(/^(archive|unarchive|approve|unapprove)/)
          responses['422'] = {
            description: 'Unprocessable Entity',
            content: {
              'application/json' => {
                schema: build_error_response_schema
              }
            }
          }
        end

        # Add other error responses
        responses.merge!({
                           '400' => { description: 'Bad Request' },
                           '401' => { description: 'Unauthorized' },
                           '403' => { description: 'Forbidden' },
                           '404' => { description: 'Not Found' },
                           '500' => { description: 'Internal Server Error' }
                         })

        responses
      end

      def build_schema_properties(_resource_doc)
        # Use simple object format (not JSON:API)
        { type: 'object' }
      end

      def build_error_response_schema
        {
          type: 'object',
          properties: {
            ok: { type: 'boolean', enum: [false] },
            transform_key('errors') => {
              type: 'array',
              items: { '$ref' => '#/components/schemas/Error' }
            }
          },
          required: ['ok', transform_key('errors')]
        }
      end

      def build_response_schema(_resource_doc, resource_name = nil, action = nil, metadata = nil)
        # Try to resolve contract for this action
        controller_class = metadata[:controller_class] if metadata
        contract_class = nil

        contract_class = Contract::Resolver.resolve(controller_class, action) if controller_class

        # If we have a contract with output definition, use it
        if contract_class&.output_definition
          data_schema = build_openapi_from_definition(contract_class.output_definition)
          ok_key = transform_key('ok')

          # Build response with ok field and data
          response_schema = {
            type: 'object',
            properties: {
              ok_key => { type: 'boolean', enum: [true] }
            },
            required: [ok_key]
          }

          # Add data (except for destroy actions)
          unless action == :destroy || action.to_s == 'destroy'
            wrapper_key = transform_key('data')
            response_schema[:properties][wrapper_key] = data_schema
            response_schema[:required] << wrapper_key
          end

          return response_schema
        end

        # Fall back to original logic using resource schemas
        if resource_name
          schema_name = resource_name.to_s.singularize.camelize
          is_collection = action == :index || action.to_s == 'index' || action.to_s.match?(/^(export|search|bulk)/)

          # Determine wrapper key based on root_key strategy
          wrapper_key = if metadata
                          determine_wrapper_key(resource_name, metadata, is_collection)
                        else
                          transform_key('data')
                        end

          # Determine data schema based on action
          data_schema = if is_collection
                          { type: 'array', items: { '$ref' => "#/components/schemas/#{schema_name}" } }
                        else
                          { '$ref' => "#/components/schemas/#{schema_name}" }
                        end

          # Build response schema with ok field
          ok_key = transform_key('ok')
          response_schema = {
            type: 'object',
            properties: {
              ok_key => { type: 'boolean', enum: [true] }
            },
            required: [ok_key]
          }

          # Add the wrapper key dynamically (except for destroy actions)
          unless action == :destroy || action.to_s == 'destroy'
            response_schema[:properties][wrapper_key] = data_schema
            response_schema[:required] << wrapper_key
          end

          # Add meta based on action type
          if action == :index || action.to_s == 'index'
            # Index actions get pagination meta
            response_schema[:properties][transform_key('meta')] = {
              type: 'object',
              properties: {
                transform_key('page') => { type: 'integer' },
                transform_key('per_page') => { type: 'integer' },
                transform_key('total') => { type: 'integer' }
              }
            }
          elsif action != :destroy && action.to_s != 'destroy'
            # Non-destroy actions get flexible meta
            response_schema[:properties][transform_key('meta')] = {
              type: 'object',
              additionalProperties: true
            }
          end
          # Destroy actions get no meta

          response_schema
        else
          # Fallback to generic object
          ok_key = transform_key('ok')
          data_key = transform_key('data')
          meta_key = transform_key('meta')
          {
            type: 'object',
            properties: {
              ok_key => { type: 'boolean', enum: [true] },
              data_key => {
                oneOf: [
                  { type: 'object' },
                  { type: 'array', items: { type: 'object' } }
                ]
              },
              meta_key => {
                type: 'object',
                additionalProperties: true
              }
            },
            required: [ok_key]
          }
        end
      end

      def build_tags_for_operation(action_doc, resource_doc)
        tags = []

        # Add resource-level tags
        tags.concat(Array(resource_doc[:tags])) if resource_doc[:tags]

        # Add action-level tags
        tags.concat(Array(action_doc[:tags])) if action_doc&.dig(:tags)

        tags.uniq
      end

      def build_contact(contact_doc)
        return nil unless contact_doc

        {
          name: contact_doc[:name],
          email: contact_doc[:email],
          url: contact_doc[:url]
        }.compact
      end

      def build_license(license_doc)
        return nil unless license_doc

        {
          name: license_doc[:name],
          url: license_doc[:url]
        }.compact
      end

      def build_components
        {
          schemas: build_schemas,
          securitySchemes: build_security_schemes
        }.compact
      end

      def build_schemas
        schemas = {}

        # Get API metadata to access all resources
        api = Apiwork::API.find(@path)
        return schemas unless api

        # Generate schemas for all resources recursively
        build_resource_schemas(schemas, api.metadata.resources)

        # Add base schemas for simple object format
        schemas.merge!(build_base_schemas)

        schemas
      end

      def build_resource_schemas(schemas, resources)
        resources.each do |resource_name, metadata|
          # Generate schema for this resource
          resource_schema = build_single_resource_schema(resource_name, metadata)
          schemas[resource_schema[:name]] = resource_schema[:schema]

          # Recursively generate schemas for nested resources
          build_resource_schemas(schemas, metadata[:resources]) if metadata[:resources]&.any?
        end
      end

      def build_single_resource_schema(resource_name, metadata)
        # Get the actual Resource class to introspect attributes
        resource_class = metadata[:resource_class]

        if resource_class
          # Use introspection to get actual attributes
          attributes = introspect_resource_attributes(resource_class)
          relationships = introspect_resource_relationships(resource_class)
        else
          # Fallback to basic schema
          attributes = build_basic_attributes(resource_name)
          relationships = {}
        end

        schema_name = resource_name.to_s.singularize.camelize

        # Build flat object schema (not JSON:API format)
        properties = {
          transform_key('id') => { type: 'string', format: 'uuid' },
          transform_key('created_at') => { type: 'string', format: 'date-time' },
          transform_key('updated_at') => { type: 'string', format: 'date-time' }
        }

        # Add all attributes directly to the root object
        properties.merge!(attributes)

        # Add relationships as nested objects
        relationships.each do |rel_name, rel_schema|
          properties[rel_name] = rel_schema
        end

        {
          name: schema_name,
          schema: {
            type: 'object',
            properties: properties,
            required: ['id']
          }
        }
      end

      def introspect_resource_attributes(resource_class)
        return {} unless resource_class.respond_to?(:attribute_definitions)

        attributes = {}
        resource_class.attribute_definitions.each do |name, definition|
          attributes[transform_key(name.to_s)] = build_attribute_schema(definition)
        end

        attributes
      end

      def introspect_resource_relationships(resource_class)
        return {} unless resource_class.respond_to?(:association_definitions)

        relationships = {}
        resource_class.association_definitions.each do |name, definition|
          relationships[transform_key(name.to_s)] = build_relationship_schema(definition)
        end

        relationships
      end

      def build_attribute_schema(definition)
        # Map Apiwork types to OpenAPI types
        case definition.type
        when :string
          { type: 'string' }
        when :integer
          { type: 'integer' }
        when :float, :decimal
          { type: 'number', format: 'float' }
        when :boolean
          { type: 'boolean' }
        when :datetime
          { type: 'string', format: 'date-time' }
        when :date
          { type: 'string', format: 'date' }
        when :uuid
          { type: 'string', format: 'uuid' }
        when :text
          { type: 'string' }
        else
          { type: 'string' }
        end
      end

      def build_relationship_schema(definition)
        # Smart logic: serializable: true → required (always included)
        # serializable: false → nullable/optional (only via includes parameter)
        description = if definition.serializable?
                        'Always included in responses'
                      else
                        "Only included when explicitly requested via ?include=#{definition.name}"
                      end

        schema = {
          type: 'object',
          description: description,
          properties: {
            data: {
              type: definition.type == :has_many ? 'array' : 'object',
              items: if definition.type == :has_many
                       {
                         type: 'object',
                         properties: {
                           id: { type: 'string', format: 'uuid' },
                           type: { type: 'string' }
                         }
                       }
                     else
                       {
                         type: 'object',
                         properties: {
                           id: { type: 'string', format: 'uuid' },
                           type: { type: 'string' }
                         }
                       }
                     end
            }
          }
        }

        # Add nullable: true for serializable: false (optional associations)
        schema[:nullable] = true unless definition.serializable?

        schema
      end

      def build_basic_attributes(_resource_name)
        # Fallback attributes for resources without Resource classes
        {
          transform_key('name') => { type: 'string' },
          transform_key('created_at') => { type: 'string', format: 'date-time' },
          transform_key('updated_at') => { type: 'string', format: 'date-time' }
        }
      end

      def build_base_schemas
        {
          'Error' => {
            type: 'object',
            properties: {
              transform_key('code') => { type: 'string' },
              transform_key('path') => { type: 'array', items: { type: 'string' } },
              transform_key('pointer') => { type: 'string' },
              transform_key('detail') => { type: 'string' },
              transform_key('options') => { type: 'object' }
            }
          }
        }
      end

      def build_security_schemes
        {
          bearerAuth: {
            type: 'http',
            scheme: 'bearer',
            bearerFormat: 'JWT'
          }
        }
      end

      def build_tags
        # Collect all unique tags from resources and actions
        tags = Set.new

        @documentation[:resources].each_value do |resource_doc|
          tags.merge(Array(resource_doc[:tags])) if resource_doc[:tags]

          # Add tags from actions
          %i[actions members collections].each do |action_type|
            resource_doc[action_type]&.each_value do |action_doc|
              tags.merge(Array(action_doc[:tags])) if action_doc[:tags]
            end
          end
        end

        tags.map { |tag| { name: tag } }
      end

      # Build OpenAPI schema from Contract::Definition
      def build_openapi_from_definition(definition)
        return nil unless definition

        schema = {
          type: 'object',
          properties: {},
          required: []
        }

        definition.params.each do |name, param_options|
          schema[:properties][name.to_s] = build_openapi_property(definition, param_options)
          schema[:required] << name.to_s if param_options[:required]
        end

        schema.delete(:required) if schema[:required].empty?
        schema
      end

      def build_openapi_property(definition, options)
        # Handle union types
        if options[:type] == :union
          return build_openapi_union(definition, options[:union])
        end

        # Handle custom types
        if options[:custom_type]
          return build_openapi_from_definition(options[:nested])
        end

        base = case options[:type]
               when :string
                 { type: 'string' }
               when :integer
                 { type: 'integer' }
               when :boolean
                 { type: 'boolean' }
               when :uuid
                 { type: 'string', format: 'uuid' }
               when :datetime
                 { type: 'string', format: 'date-time' }
               when :date
                 { type: 'string', format: 'date' }
               when :decimal, :float
                 { type: 'number', format: 'float' }
               when :object
                 if options[:nested]
                   build_openapi_from_definition(options[:nested])
                 else
                   { type: 'object' }
                 end
               when :array
                 items = if options[:of]
                           # Check if 'of' is a custom type
                           if definition.contract_class.custom_types&.key?(options[:of])
                             custom_type_block = definition.contract_class.custom_types[options[:of]]
                             custom_def = Contract::Definition.new(definition.type, definition.contract_class)
                             custom_def.instance_eval(&custom_type_block)
                             build_openapi_from_definition(custom_def)
                           else
                             build_openapi_property(definition, type: options[:of])
                           end
                         elsif options[:nested]
                           build_openapi_from_definition(options[:nested])
                         else
                           { type: 'object' }
                         end
                 { type: 'array', items: }
               else
                 { type: 'string' }
               end

        base[:enum] = options[:enum] if options[:enum]
        base[:description] = options[:description] if options[:description]
        base[:default] = options[:default] if options[:default]

        base
      end

      # Build OpenAPI oneOf for union type
      def build_openapi_union(definition, union_def)
        variants = union_def.variants.map do |variant_def|
          build_openapi_variant(definition, variant_def)
        end

        { oneOf: variants }
      end

      # Build OpenAPI schema for a single variant
      def build_openapi_variant(definition, variant_def)
        type = variant_def[:type]

        # Check if type is a custom type
        if definition.contract_class.custom_types&.key?(type)
          custom_type_block = definition.contract_class.custom_types[type]
          custom_def = Contract::Definition.new(definition.type, definition.contract_class)
          custom_def.instance_eval(&custom_type_block)
          return build_openapi_from_definition(custom_def)
        end

        # Handle nested object variant
        if variant_def[:nested]
          return build_openapi_from_definition(variant_def[:nested])
        end

        # Handle array variant
        if type == :array
          items = if variant_def[:of]
                    # Check if 'of' is a custom type
                    if definition.contract_class.custom_types&.key?(variant_def[:of])
                      custom_type_block = definition.contract_class.custom_types[variant_def[:of]]
                      custom_def = Contract::Definition.new(definition.type, definition.contract_class)
                      custom_def.instance_eval(&custom_type_block)
                      build_openapi_from_definition(custom_def)
                    else
                      build_openapi_property(definition, type: variant_def[:of])
                    end
                  elsif variant_def[:nested]
                    build_openapi_from_definition(variant_def[:nested])
                  else
                    { type: 'object' }
                  end
          return { type: 'array', items: }
        end

        # Handle primitive type variant
        property = build_openapi_property(definition, type: type)
        property[:enum] = variant_def[:enum] if variant_def[:enum]
        property
      end
    end
  end
end
