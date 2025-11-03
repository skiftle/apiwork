# frozen_string_literal: true

module Apiwork
  class APIInspector
    class << self
      # Resource introspection - returns resource definitions with attributes and associations
      # Query params and body params are derived from attribute options
      #
      # @param path [String] The API path (e.g., '/api/v1', 'api/v1')
      def resources(path:)
        api_class = find_api(path)
        return [] unless api_class&.metadata

        collect_resources(api_class.metadata)
      end

      # Route introspection - returns API endpoints with method, path, input, output
      #
      # @param path [String] The API path (e.g., '/api/v1', 'api/v1')
      def routes(path:)
        api_class = find_api(path)
        return {} unless api_class&.metadata

        collect_routes(api_class.metadata)
      end

      # Input introspection - returns input class definitions for member/collection actions
      #
      # @param path [String] The API path (e.g., '/api/v1', 'api/v1')
      def inputs(path:)
        api_class = find_api(path)
        return [] unless api_class&.metadata

        collect_inputs(api_class.metadata)
      end

      # Documentation introspection - returns API and resource documentation
      #
      # @param path [String] The API path (e.g., '/api/v1', 'api/v1')
      def documentation(path:)
        api_class = find_api(path)
        return {} unless api_class&.metadata

        {
          api: api_class.metadata.doc, # API-level documentation
          resources: collect_resource_documentation(api_class.metadata)
        }
      end

      private

      # Find API class using path
      def find_api(path)
        ::Apiwork::API.find(path)
      end

      def collect_resources(api)
        resources = []

        # Collect top-level resources
        api.resources.each do |name, metadata|
          resource_class = find_resource_class(metadata[:resource_class] || metadata[:resource_class_name])
          next unless resource_class

          resources << build_resource_definition(name, resource_class, metadata)
        end

        # Collect nested resources recursively
        api.resources.each_value do |metadata|
          collect_nested_resources(metadata[:resources] || {}, resources)
        end

        resources
      end

      def collect_nested_resources(nested_resources, resources)
        nested_resources.each do |name, metadata|
          resource_class = find_resource_class(metadata[:resource_class] || metadata[:resource_class_name])
          next unless resource_class

          resources << build_resource_definition(name, resource_class, metadata)

          # Recursively collect deeper nested resources
          collect_nested_resources(metadata[:resources] || {}, resources)
        end
      end

      def collect_routes(api)
        routes = {}

        api.resources.each do |name, metadata|
          routes[name] = build_route_definition(name, metadata)
        end

        routes
      end

      def collect_inputs(api)
        inputs = []

        # Collect inputs from top-level resources
        api.resources.each_value do |metadata|
          collect_inputs_from_metadata(metadata, inputs)
        end

        inputs
      end

      def collect_inputs_from_metadata(metadata, inputs)
        # Collect member action inputs
        metadata[:members]&.each do |action_name, action_info|
          next unless action_info[:input_class]

          input_class = find_input_class(action_info[:input_class])
          inputs << build_input_definition(input_class, action_name, 'member') if input_class
        end

        # Collect collection action inputs
        metadata[:collections]&.each do |action_name, action_info|
          next unless action_info[:input_class]

          input_class = find_input_class(action_info[:input_class])
          inputs << build_input_definition(input_class, action_name, 'collection') if input_class
        end

        # Recursively collect from nested resources
        metadata[:resources]&.each_value do |nested_metadata|
          collect_inputs_from_metadata(nested_metadata, inputs)
        end
      end

      def build_resource_definition(name, resource_class, _metadata)
        {
          name: name.to_s.singularize.underscore,
          class_name: resource_class.name,
          namespaces: resource_class.name.deconstantize.split('::'),
          type: name.to_s.singularize,
          root_key: resource_class.root_key,
          attributes: extract_attributes(resource_class),
          associations: extract_associations(resource_class)
        }
      end

      def build_route_definition(_name, metadata)
        {
          singular: metadata[:singular],
          resource_class_name: metadata[:resource_class] || metadata[:resource_class_name],
          actions: metadata[:actions] || [],
          members: process_actions(metadata[:members] || {}),
          collections: process_actions(metadata[:collections] || {}),
          routes: process_nested_routes(metadata[:resources] || {})
        }
      end

      def process_actions(actions)
        actions.transform_values do |action_info|
          {
            method: action_info[:method],
            options: action_info[:options] || {},
            input_class_name: action_info[:input_class] || action_info[:input_class_name]
          }
        end
      end

      def process_nested_routes(routes)
        routes.transform_values do |route_metadata|
          build_route_definition(nil, route_metadata)
        end
      end

      def build_input_definition(input_class, _action_name, _type)
        {
          name: input_class.name.demodulize.underscore.gsub(/_input$/, ''),
          class_name: input_class.name,
          namespaces: input_class.name.deconstantize.split('::'),
          params: extract_input_params(input_class)
        }
      end

      def extract_attributes(resource_class)
        attributes = {}

        resource_class.attribute_definitions.each do |name, definition|
          attributes[name] = {
            type: definition.type || 'string',
            filterable: definition.filterable? || false,
            sortable: definition.sortable? || false,
            writable: definition.writable? || false,
            required: definition.required? || false
          }
        end

        attributes
      end

      def extract_associations(resource_class)
        associations = {}

        resource_class.association_definitions.each do |name, definition|
          associations[name] = {
            type: definition.type || 'has_many',
            resource_class_name: definition.resource_class&.name,
            writable: definition.writable? || false,
            serializable: definition.serializable? || false
          }
        end

        associations
      end

      def extract_input_params(input_class)
        params = {}

        # Extract params from input class using the param DSL
        if input_class.respond_to?(:param_definitions)
          input_class.param_definitions.each do |name, options|
            params[name] = {
              type: options[:type] || 'string',
              required: options[:required] || false,
              default: options[:default]
            }
          end
        end

        params
      end

      def find_resource_class(class_name)
        return nil unless class_name

        # If it's already a class, return it
        return class_name if class_name.is_a?(Class)

        # Otherwise, constantize the string
        class_name.constantize
      rescue NameError
        nil
      end

      def find_input_class(class_name)
        return nil unless class_name

        # If it's already a class, return it
        return class_name if class_name.is_a?(Class)

        # Otherwise, constantize the string
        class_name.constantize
      rescue NameError
        nil
      end

      # NEW: Collect resource documentation recursively
      def collect_resource_documentation(api)
        documentation = {}

        api.resources.each do |name, metadata|
          documentation[name] = metadata[:doc] if metadata[:doc]

          # Recursively collect from nested resources
          if metadata[:resources]
            nested_docs = collect_resource_documentation_from_metadata(metadata[:resources])
            documentation.merge!(nested_docs) if nested_docs.present?
          end
        end

        documentation
      end

      def collect_resource_documentation_from_metadata(resources)
        documentation = {}

        resources.each do |name, metadata|
          documentation[name] = metadata[:doc] if metadata[:doc]

          # Recursively collect from deeper nested resources
          if metadata[:resources]
            nested_docs = collect_resource_documentation_from_metadata(metadata[:resources])
            documentation.merge!(nested_docs) if nested_docs.present?
          end
        end

        documentation
      end
    end
  end
end
