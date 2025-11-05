# frozen_string_literal: true

module Apiwork
  class Inspector
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
            options: action_info[:options] || {}
          }
        end
      end

      def process_nested_routes(routes)
        routes.transform_values do |route_metadata|
          build_route_definition(nil, route_metadata)
        end
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
          # Auto-detect resource class if not explicitly provided
          resolved_resource_class = definition.resource_class
          reflection = resource_class.model_class&.reflect_on_association(name)

          if resolved_resource_class.nil? && resource_class.model_class
            resolved_resource_class = Resource::Resolver.from_association(reflection, resource_class)
          end

          # Constantize if string
          resolved_resource_class = resolved_resource_class.constantize if resolved_resource_class.is_a?(String)

          # Extract resource name (e.g., "Address" from "Api::V1::AddressResource")
          resource_name = resolved_resource_class&.name&.demodulize&.sub(/Resource$/, '')

          # Determine if association is nullable
          # For belongs_to: auto-detected from DB constraint unless explicitly set
          # For has_one/has_many: use explicit nullable option or default to false
          nullable = definition.nullable?

          associations[name] = {
            name: resource_name&.underscore,
            kind: definition.type.to_s, # has_one, has_many, belongs_to
            resource_class_name: resolved_resource_class&.name,
            nullable: nullable,
            writable: definition.writable? || false,
            serializable: definition.serializable? || false
          }
        end

        associations
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
