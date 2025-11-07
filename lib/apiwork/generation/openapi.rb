# frozen_string_literal: true

module Apiwork
  module Generation
    # OpenAPI 3.1.0 generator using API.as_json with smart deduplication
    #
    # Generates OpenAPI specifications from API introspection data.
    # Uses ComponentRegistry for schema deduplication and ContractMapper for conversion.
    #
    # @example Generate OpenAPI spec
    #   generator = OpenAPI.new('/api/v1')
    #   spec = generator.generate
    #   File.write('openapi.json', JSON.pretty_generate(spec))
    class OpenAPI < Base
      generator_name :openapi
      content_type 'application/json'

      def self.file_extension
        '.json'
      end

      # Generate OpenAPI 3.1.0 specification
      #
      # @return [Hash] OpenAPI specification
      def generate
        {
          openapi: '3.1.0',
          info: build_info,
          paths: build_paths,
          components: {
            schemas: build_component_schemas
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

        each_resource do |resource_name, resource_data|
          build_resource_paths(paths, resource_name, resource_data)
        end

        paths
      end

      # Build paths for a single resource
      def build_resource_paths(paths, resource_name, resource_data)
        resource_path = resource_data[:path]

        # CRUD actions
        resource_data[:actions]&.each do |action_name|
          contract = resource_data[:contracts]&.[](action_name)
          next unless contract

          action_path = action_path_for(resource_path, action_name)
          method = http_method_for_action(action_name).downcase

          paths[action_path] ||= {}
          paths[action_path][method] = build_operation(
            resource_name,
            action_name,
            contract
          )
        end

        # Member actions
        resource_data[:members]&.each do |action_name, action_data|
          contract = action_data[:contract]
          next unless contract

          action_path = action_data[:path]
          method = action_data[:method].to_s.downcase

          paths[action_path] ||= {}
          paths[action_path][method] = build_operation(
            resource_name,
            action_name,
            contract
          )
        end

        # Collection actions
        resource_data[:collections]&.each do |action_name, action_data|
          contract = action_data[:contract]
          next unless contract

          action_path = action_data[:path]
          method = action_data[:method].to_s.downcase

          paths[action_path] ||= {}
          paths[action_path][method] = build_operation(
            resource_name,
            action_name,
            contract
          )
        end
      end

      # Build path for a CRUD action
      def action_path_for(resource_path, action_name)
        case action_name
        when :show, :update, :destroy
          "#{resource_path}/:id"
        else
          resource_path
        end
      end

      # Build OpenAPI operation object
      def build_operation(resource_name, action_name, contract)
        operation = {
          operationId: operation_id(resource_name, action_name),
          tags: [resource_name.to_s.camelize],
          responses: build_responses(resource_name, action_name, contract[:output])
        }

        # Add requestBody if action has input
        if contract[:input]
          operation[:requestBody] = build_request_body(resource_name, action_name, contract[:input])
        end

        operation.compact
      end

      # Build operation ID
      def operation_id(resource_name, action_name)
        "#{action_name}_#{resource_name}"
      end

      # Build OpenAPI requestBody
      def build_request_body(resource_name, action_name, input_definition)
        # Build component name that matches what ComponentRegistry created
        input_component_name = build_component_name("#{action_name}_#{resource_name.to_s.singularize}_input")

        {
          required: true,
          content: {
            'application/json': {
              schema: {
                '$ref': "#/components/schemas/#{input_component_name}"
              }
            }
          }
        }
      end

      # Build OpenAPI responses
      def build_responses(resource_name, action_name, output_definition)
        return default_responses unless output_definition

        # Build component name that matches what ComponentRegistry created
        # Output naming: index => PostList, others => Post
        output_component_name = case action_name
                                when :index
                                  build_component_name("#{resource_name.to_s.singularize}_list")
                                else
                                  build_component_name(resource_name.to_s.singularize)
                                end

        {
          '200': {
            description: 'Successful response',
            content: {
              'application/json': {
                schema: {
                  '$ref': "#/components/schemas/#{output_component_name}"
                }
              }
            }
          }
        }
      end

      # Build component name (PascalCase from snake_case)
      def build_component_name(snake_case_name)
        snake_case_name.to_s.split('_').map(&:capitalize).join
      end

      # Default responses when no output contract
      def default_responses
        {
          '204': {
            description: 'No content'
          }
        }
      end

      # Build all component schemas using ComponentRegistry
      def build_component_schemas
        mapper = ContractMapper::OpenAPI.new(component_registry)
        schemas = {}

        component_registry.components.each do |component_name, definition|
          schemas[component_name] = mapper.map(definition)
        end

        schemas
      end
    end
  end
end
