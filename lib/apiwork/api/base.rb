# frozen_string_literal: true

module Apiwork
  module API
    # Base class for API definitions
    #
    # Define APIs using a declarative DSL:
    #
    # @example Basic API
    #   class V1API < Apiwork::API
    #     namespaces :api, :v1
    #     schema :openapi
    #     schema :transport
    #     schema :zod
    #
    #     resources :accounts do
    #       resources :clients
    #     end
    #   end
    #
    # @example API with documentation
    #   class V1API < Apiwork::API
    #     namespaces :api, :v1
    #     schema :openapi
    #     schema :transport
    #
    #     doc do
    #       title "My API"
    #       version "1.0.0"
    #     end
    #
    #     resources :accounts, concerns: [:auditable]
    #   end
    class Base
      extend Configuration   # Adds: configure_from_path, mount_at, schema
      extend Documentation   # Adds: doc
      extend Routing         # Adds: resources, resource, concern, with_options

      class << self
        attr_reader :metadata, :recorder, :mount_path, :namespaces_parts, :schemas

        # Get controller namespace derived from namespaces parts
        #
        # @return [String] Controller namespace (e.g., "Api::V1")
        def controller_namespace
          namespaces_parts.map(&:to_s).map(&:camelize).join('::')
        end

        # Serialize entire API to JSON-friendly hash
        # Returns complete API structure with metadata, resources, and contracts
        # @return [Hash] Complete API introspection
        def as_json
          return nil unless metadata

          result = {
            path: mount_path,
            metadata: serialize_doc,
            types: serialize_all_types,
            resources: {}
          }

          # Serialize each resource
          metadata.resources.each do |resource_name, resource_metadata|
            result[:resources][resource_name] = serialize_resource(resource_name, resource_metadata)
          end

          result
        end

        private

        # Serialize documentation metadata
        def serialize_doc
          return nil unless metadata.doc

          {
            title: metadata.doc[:title],
            version: metadata.doc[:version],
            description: metadata.doc[:description]
          }.compact
        end

        # Serialize all types from TypeRegistry
        # Returns all global types + all local types from all contracts in a single hash
        def serialize_all_types
          Contract::TypeRegistry.serialize_all_types_for_api(self)
        end

        # Serialize a single resource with all its actions and metadata
        def serialize_resource(resource_name, resource_metadata, parent_path: nil)
          resource_path = build_resource_path(resource_name, resource_metadata, parent_path)

          result = {
            path: resource_path,
            singular: resource_metadata[:singular],
            actions: resource_metadata[:actions] || [],
            contracts: {}
          }

          # Get contract class for this resource
          # Try explicit contract first, fall back to schema-based contract
          contract_class = resolve_contract_class(resource_metadata) ||
                          schema_based_contract_class(resource_metadata)

          # Serialize CRUD actions
          (resource_metadata[:actions] || []).each do |action_name|
            if contract_class
              action_def = contract_class.action_definition(action_name)
              result[:contracts][action_name] = action_def&.as_json
            end
          end

          # Serialize member actions
          if resource_metadata[:members]&.any?
            result[:members] = {}
            resource_metadata[:members].each do |action_name, action_metadata|
              result[:members][action_name] = serialize_action(
                action_name,
                action_metadata,
                resource_path,
                :member,
                contract_class
              )
            end
          end

          # Serialize collection actions
          if resource_metadata[:collections]&.any?
            result[:collections] = {}
            resource_metadata[:collections].each do |action_name, action_metadata|
              result[:collections][action_name] = serialize_action(
                action_name,
                action_metadata,
                resource_path,
                :collection,
                contract_class
              )
            end
          end

          # Serialize nested resources
          if resource_metadata[:resources]&.any?
            result[:resources] = {}
            resource_metadata[:resources].each do |nested_name, nested_metadata|
              result[:resources][nested_name] = serialize_resource(
                nested_name,
                nested_metadata,
                parent_path: resource_path
              )
            end
          end

          result
        end

        # Serialize a member or collection action
        def serialize_action(action_name, action_metadata, resource_path, action_type, contract_class)
          action_path = if action_type == :member
                          "#{resource_path}/:id/#{action_name}"
                        else
                          "#{resource_path}/#{action_name}"
                        end

          result = {
            method: action_metadata[:method],
            path: action_path
          }

          # Add contract if available
          if contract_class
            action_def = contract_class.action_definition(action_name)
            result[:contract] = action_def&.as_json if action_def
          end

          result
        end

        # Build full path for a resource
        def build_resource_path(resource_name, resource_metadata, parent_path)
          resource_segment = if resource_metadata[:singular]
                               resource_name.to_s.singularize
                             else
                               resource_name.to_s
                             end

          if parent_path
            "#{parent_path}/:id/#{resource_segment}"
          else
            "#{mount_path}/#{resource_segment}"
          end
        end

        # Resolve contract class from resource metadata
        # Only returns explicit contract classes (not schema-based)
        def resolve_contract_class(resource_metadata)
          return nil unless resource_metadata[:contract_class_name]

          # Try to constantize the contract class name
          resource_metadata[:contract_class_name].constantize
        rescue NameError
          # Contract class doesn't exist
          nil
        end

        # Get or create schema-based contract class for a resource
        # This uses caching to avoid creating multiple instances
        # Safe to use thanks to circular reference protection in serialization
        # CRITICAL: Cache by root_key (not schema class name) to share types across subclasses
        # Example: PostSchema and RestrictedPostSchema both have root_key "post", so they share contract class
        def schema_based_contract_class(resource_metadata)
          return nil unless resource_metadata[:schema_class]

          schema_class = resource_metadata[:schema_class]

          # Cache key based on schema class name to prevent infinite recursion
          # Use object_id as fallback for anonymous classes
          # Replace :: with _ to make valid instance variable name
          cache_key = if schema_class.name
                       :"contract_#{schema_class.name.tr('::', '_')}"
                     else
                       :"contract_#{schema_class.object_id}"
                     end

          # Return cached if available
          return instance_variable_get("@#{cache_key}") if instance_variable_defined?("@#{cache_key}")

          # Create new anonymous contract class with schema
          # Circular references are handled in Generator via visited set (checked BEFORE accessing root_key)
          contract_class = Class.new(Apiwork::Contract::Base) do
            schema schema_class
          end

          # Cache it
          instance_variable_set("@#{cache_key}", contract_class)
          contract_class
        end
      end
    end
  end
end
