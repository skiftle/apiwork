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
        # Returns complete API structure with metadata, resources, contracts, types, and enums
        # @return [Hash] Complete API introspection
        def as_json
          return nil unless metadata

          # Build resources first - this creates contract classes and registers types/enums
          resources = {}
          metadata.resources.each do |resource_name, resource_metadata|
            resources[resource_name] = serialize_resource(resource_name, resource_metadata)
          end

          # Now collect all types and enums (after contract classes have been created)
          result = {
            path: mount_path,
            metadata: serialize_doc,
            types: serialize_all_types,
            enums: serialize_all_enums,
            resources: resources
          }

          # Add global error codes at root level if defined
          result[:error_codes] = metadata.error_codes if metadata.error_codes&.any?

          result
        end

        private

        # Serialize documentation metadata
        def serialize_doc
          result = {}

          if metadata.doc
            result[:title] = metadata.doc[:title]
            result[:version] = metadata.doc[:version]
            result[:description] = metadata.doc[:description]
          end

          result.compact.presence
        end

        # Serialize all types from Descriptors::Registry
        # Returns all global types + all local types from all contracts in a single hash
        def serialize_all_types
          Contract::Descriptors::Registry.serialize_all_types_for_api(self)
        end

        # Serialize all enums from Descriptors::Registry
        # Returns all global enums + all local enums from all scopes in a single hash
        def serialize_all_enums
          Contract::Descriptors::Registry.serialize_all_enums_for_api(self)
        end

        # Serialize a single resource with all its actions and metadata
        def serialize_resource(resource_name, resource_metadata, parent_path: nil, parent_resource_name: nil)
          resource_path = build_resource_path(resource_name, resource_metadata, parent_path,
                                              parent_resource_name: parent_resource_name)

          result = {
            path: resource_path, # Resource-level relative path
            actions: {}
          }

          # Get contract class for this resource
          # Try explicit contract first, fall back to schema-based contract
          contract_class = resolve_contract_class(resource_metadata) ||
                           schema_based_contract_class(resource_metadata)

          # Serialize CRUD actions
          (resource_metadata[:actions] || []).each do |action_name|
            method = crud_action_method(action_name)
            path = build_action_path(resource_path, action_name, action_name.to_sym)
            add_action_with_contract(result[:actions], action_name, method, path, contract_class)
          end

          # Serialize member actions
          if resource_metadata[:members]&.any?
            resource_metadata[:members].each do |action_name, action_metadata|
              path = build_action_path(resource_path, action_name, :member)
              add_action_with_contract(result[:actions], action_name, action_metadata[:method], path, contract_class)
            end
          end

          # Serialize collection actions
          if resource_metadata[:collections]&.any?
            resource_metadata[:collections].each do |action_name, action_metadata|
              path = build_action_path(resource_path, action_name, :collection)
              add_action_with_contract(result[:actions], action_name, action_metadata[:method], path, contract_class)
            end
          end

          # Serialize nested resources
          if resource_metadata[:resources]&.any?
            result[:resources] = {}
            resource_metadata[:resources].each do |nested_name, nested_metadata|
              result[:resources][nested_name] = serialize_resource(
                nested_name,
                nested_metadata,
                parent_path: resource_path,
                parent_resource_name: resource_name
              )
            end
          end

          result
        end

        # Map CRUD action names to HTTP methods
        def crud_action_method(action_name)
          case action_name.to_sym
          when :index then :get
          when :show then :get
          when :create then :post
          when :update then :patch
          when :destroy then :delete
          else :get
          end
        end

        # Build relative path for any action type
        # Returns only the action-specific segment with generic :id
        # index/create: "/"
        # show/update/destroy: "/:id"
        # member: "/:id/action_name"
        # collection: "/action_name"
        def build_action_path(resource_path, action_name, action_type)
          case action_type
          when :index, :create
            '/'
          when :show, :update, :destroy
            '/:id'
          when :member
            "/:id/#{action_name}"
          when :collection
            "/#{action_name}"
          else
            '/'
          end
        end

        # Add action with method, path, and contract input/output
        def add_action_with_contract(actions, name, method, path, contract_class)
          actions[name] = { method:, path: }

          return unless contract_class

          action_definition = contract_class.action_definition(name)
          return unless action_definition

          contract_json = action_definition.as_json
          actions[name][:input] = contract_json[:input] || {}
          actions[name][:output] = contract_json[:output] || {}
          actions[name][:error_codes] = contract_json[:error_codes] if contract_json[:error_codes]
        end

        # Build relative path for a resource
        # Returns only the local segment, not the full absolute path
        # Top-level: "posts"
        # Nested: ":post_id/comments"
        def build_resource_path(resource_name, resource_metadata, parent_path, parent_resource_name: nil)
          resource_segment = if resource_metadata[:singular]
                               resource_name.to_s.singularize
                             else
                               resource_name.to_s
                             end

          if parent_path
            # Nested: use parent resource name for ID parameter
            parent_id_param = ":#{parent_resource_name.to_s.singularize}_id"
            "#{parent_id_param}/#{resource_segment}"
          else
            # Top-level: just the resource segment
            resource_segment
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
