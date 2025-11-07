# frozen_string_literal: true

module Apiwork
  module API
    class Inspector
      class << self
      # Schema introspection - returns schema definitions with attributes and associations
      # Query params and body params are derived from attribute options
      #
      # @param path [String] The API path (e.g., '/api/v1', 'api/v1')
      def resources(path:)
        api_class = find_api(path)
        return [] unless api_class&.metadata

        collect_schemas(api_class.metadata)
      end

      # Route introspection - returns API endpoints with method, path, input, output
      #
      # @param path [String] The API path (e.g., '/api/v1', 'api/v1')
      def routes(path:)
        api_class = find_api(path)
        return {} unless api_class&.metadata

        collect_routes(api_class.metadata)
      end

      # Documentation introspection - returns API and schema documentation
      #
      # @param path [String] The API path (e.g., '/api/v1', 'api/v1')
      def documentation(path:)
        api_class = find_api(path)
        return {} unless api_class&.metadata

        {
          api: api_class.metadata.doc, # API-level documentation
          resources: collect_schema_documentation(api_class.metadata)
        }
      end

      private

      # Find API class using path
      def find_api(path)
        ::Apiwork::API.find(path)
      end

      def collect_schemas(api)
        schemas = []

        # Collect top-level schemas from REST resources
        api.resources.each do |name, metadata|
          schema_class = find_schema_class(metadata[:schema_class] || metadata[:schema_class_name])
          next unless schema_class

          schemas << build_schema_definition(name, schema_class, metadata)
        end

        # Collect nested schemas recursively
        api.resources.each_value do |metadata|
          collect_nested_schemas(metadata[:resources] || {}, schemas)
        end

        schemas
      end

      def collect_nested_schemas(nested_resources, schemas)
        nested_resources.each do |name, metadata|
          schema_class = find_schema_class(metadata[:schema_class] || metadata[:schema_class_name])
          next unless schema_class

          schemas << build_schema_definition(name, schema_class, metadata)

          # Recursively collect deeper nested schemas
          collect_nested_schemas(metadata[:resources] || {}, schemas)
        end
      end

      def collect_routes(api)
        routes = {}

        api.resources.each do |name, metadata|
          routes[name] = build_route_definition(name, metadata)
        end

        routes
      end

      def build_schema_definition(name, schema_class, _metadata)
        {
          name: name.to_s.singularize.underscore,
          class_name: schema_class.name,
          namespaces: schema_class.name.deconstantize.split('::'),
          type: name.to_s.singularize,
          root_key: schema_class.root_key,
          attributes: extract_attributes(schema_class),
          associations: extract_associations(schema_class)
        }
      end

      def build_route_definition(_name, metadata)
        {
          singular: metadata[:singular],
          schema_class_name: metadata[:schema_class],
          controller_class_name: metadata[:controller_class_name],
          contract_class_name: metadata[:contract_class_name],
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
            contract_class_name: action_info[:contract_class_name],
            schema_class_name: action_info[:schema_class_name]
          }
        end
      end

      def process_nested_routes(routes)
        routes.transform_values do |route_metadata|
          build_route_definition(nil, route_metadata)
        end
      end

      def extract_attributes(schema_class)
        attributes = {}

        schema_class.attribute_definitions.each do |name, definition|
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

      def extract_associations(schema_class)
        associations = {}

        schema_class.association_definitions.each do |name, definition|
          # Auto-detect schema class if not explicitly provided
          resolved_schema_class = definition.schema_class
          reflection = schema_class.model_class&.reflect_on_association(name)

          if resolved_schema_class.nil? && schema_class.model_class
            resolved_schema_class = Schema::Resolver.from_association(reflection, schema_class)
          end

          # Constantize if string
          resolved_schema_class = resolved_schema_class.constantize if resolved_schema_class.is_a?(String)

          # Extract schema name (e.g., "Address" from "Api::V1::AddressSchema")
          schema_name = resolved_schema_class&.name&.demodulize&.sub(/Schema$/, '')

          # Determine if association is nullable
          # For belongs_to: auto-detected from DB constraint unless explicitly set
          # For has_one/has_many: use explicit nullable option or default to false
          nullable = definition.nullable?

          associations[name] = {
            name: schema_name&.underscore,
            kind: definition.type.to_s, # has_one, has_many, belongs_to
            schema_class_name: resolved_schema_class&.name,
            nullable: nullable,
            writable: definition.writable? || false,
            serializable: definition.serializable? || false
          }
        end

        associations
      end

      def find_schema_class(class_name)
        return nil unless class_name

        # If it's already a class, return it
        return class_name if class_name.is_a?(Class)

        # Otherwise, constantize the string
        class_name.constantize
      rescue NameError
        nil
      end

      # Collect schema documentation recursively
      def collect_schema_documentation(api)
        documentation = {}

        api.resources.each do |name, metadata|
          documentation[name] = metadata[:doc] if metadata[:doc]

          # Recursively collect from nested resources
          if metadata[:resources]
            nested_docs = collect_schema_documentation_from_metadata(metadata[:resources])
            documentation.merge!(nested_docs) if nested_docs.present?
          end
        end

        documentation
      end

      def collect_schema_documentation_from_metadata(resources)
        documentation = {}

        resources.each do |name, metadata|
          documentation[name] = metadata[:doc] if metadata[:doc]

          # Recursively collect from deeper nested resources
          if metadata[:resources]
            nested_docs = collect_schema_documentation_from_metadata(metadata[:resources])
            documentation.merge!(nested_docs) if nested_docs.present?
          end
        end

        documentation
      end
    end
  end
  end
end
