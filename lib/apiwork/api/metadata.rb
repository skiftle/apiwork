# frozen_string_literal: true

module Apiwork
  module API
    class Metadata
      attr_reader :path, :namespaces, :resources, :concerns
      attr_accessor :info, :error_codes

      def initialize(path)
        # Store path as source of truth
        @path = path

        # Derive namespaces from path
        @namespaces = path == '/' ? [:root] : path.split('/').reject(&:empty?).map(&:to_sym)

        @resources = {} # Structured tree, not flat array
        @concerns = {}
        @info = nil
        @error_codes = [] # Global error codes for all endpoints in this API
      end

      # Derive namespace string for class names: [:api, :v1] -> 'Api::V1'
      def namespaces_string
        @namespaces.map(&:to_s).map(&:camelize).join('::')
      end

      def add_resource(name, singular:, schema_class:, controller_class_name: nil, contract_class_name: nil,
                       parent: nil, **options)
        # Add to structured tree
        target = if parent
                   # Find or create nested resources hash
                   parent_resource = find_resource(parent)
                   return unless parent_resource

                   parent_resource[:resources] ||= {}
                 else
                   @resources
                 end

        target[name] = {
          singular: singular,
          schema_class: schema_class,
          controller_class_name: controller_class_name,
          contract_class_name: contract_class_name,
          actions: determine_actions(singular, options),
          members: {},
          collections: {},
          resources: {},
          parent: parent,
          options: options
        }
      end

      def add_member_action(resource_name, action, method:, options:, contract_class_name: nil)
        resource = find_resource(resource_name)
        return unless resource

        resource[:members][action] = {
          method: method,
          options: options,
          contract_class_name: contract_class_name
        }
      end

      def add_collection_action(resource_name, action, method:, options:, contract_class_name: nil)
        resource = find_resource(resource_name)
        return unless resource

        resource[:collections][action] = {
          method: method,
          options: options,
          contract_class_name: contract_class_name
        }
      end

      def add_concern(name, block)
        @concerns[name] = block
      end

      def merge(other_metadata)
        # Deep merge resources from multiple api blocks
        other_metadata.resources.each do |name, other_resource|
          if @resources[name]
            # Resource exists, merge nested resources
            merge_nested_resources(@resources[name], other_resource)
          else
            # New resource, add it
            @resources[name] = other_resource
          end
        end

        # Merge concerns
        @concerns.merge!(other_metadata.concerns)
      end

      def find_resource(resource_name)
        return resources[resource_name] if resources[resource_name]

        resources.each_value do |resource_metadata|
          found = find_resource_recursive(resource_metadata, resource_name)
          return found if found
        end

        nil
      end

      def search_resources(&block)
        resources.each_value do |resource_metadata|
          result = search_in_resource_tree(resource_metadata, &block)
          return result if result
        end

        nil
      end

      private

      def find_resource_recursive(resource_metadata, resource_name)
        return resource_metadata[:resources][resource_name] if resource_metadata[:resources]&.key?(resource_name)

        resource_metadata[:resources]&.each_value do |nested_metadata|
          found = find_resource_recursive(nested_metadata, resource_name)
          return found if found
        end

        nil
      end

      def search_in_resource_tree(resource_metadata, &block)
        # Check current resource
        result = yield(resource_metadata)
        return result if result

        # Search nested resources
        resource_metadata[:resources]&.each_value do |nested_metadata|
          result = search_in_resource_tree(nested_metadata, &block)
          return result if result
        end

        nil
      end

      def merge_nested_resources(target, source)
        # Merge members
        target[:members].merge!(source[:members]) if source[:members]

        # Merge collections
        target[:collections].merge!(source[:collections]) if source[:collections]

        # Recursively merge nested resources
        return unless source[:resources]

        target[:resources] ||= {}
        source[:resources].each do |name, nested_resource|
          if target[:resources][name]
            merge_nested_resources(target[:resources][name], nested_resource)
          else
            target[:resources][name] = nested_resource
          end
        end
      end

      def determine_actions(singular, options)
        only = options[:only]
        except = options[:except]

        if only
          Array(only).map(&:to_sym)
        else
          # Determine default actions based on resource type
          default_actions = if singular
                              [:show, :create, :update, :destroy] # No :index for singular
                            else
                              [:index, :show, :create, :update, :destroy]
                            end

          # Apply except filter if present
          if except
            default_actions - Array(except).map(&:to_sym)
          else
            default_actions
          end
        end
      end
    end
  end
end
