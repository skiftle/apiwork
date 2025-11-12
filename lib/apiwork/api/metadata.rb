# frozen_string_literal: true

module Apiwork
  module API
    # Stores structured metadata about API definitions for introspection and code generation
    #
    # Path is the source of truth - all other values are derived from it
    #
    # @example
    #   metadata = Metadata.new('/api/v1')
    #   metadata.path           # => '/api/v1'
    #   metadata.namespaces     # => [:api, :v1]
    #   metadata.add_resource(:accounts, singular: false, schema_class: Api::V1::AccountSchema)
    #   metadata.add_member_action(:accounts, :archive, method: :patch, options: {})
    class Metadata
      attr_reader :path, :namespaces, :resources, :concerns
      attr_accessor :doc, :error_codes

      def initialize(path)
        # Store path as source of truth
        @path = path

        # Derive namespaces from path
        @namespaces = path_to_namespaces(path)

        @resources = {}  # Structured tree, not flat array
        @concerns = {}
        @doc = nil
        @error_codes = []  # Global error codes for all endpoints in this API
      end

      # Derive namespace string for class names: [:api, :v1] -> 'Api::V1'
      def namespaces_string
        @namespaces.map(&:to_s).map(&:camelize).join('::')
      end

      # Derive namespace path for URLs: [:api, :v1] -> 'api/v1'
      # Removes leading slash from stored path
      def namespaces_path
        @path.sub(%r{^/}, '')
      end

      def add_resource(name, singular:, schema_class:, controller_class_name: nil, contract_class_name: nil, parent: nil, doc: nil, **options)
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
          options: options,
          doc: doc
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

      private

      # Convert path to namespaces array
      #
      # @param path [String] The path
      # @return [Array<Symbol>] Namespaces array
      def path_to_namespaces(path)
        return [:root] if path == '/'

        path.split('/').reject(&:empty?).map(&:to_sym)
      end

      def find_resource(name)
        searcher = MetadataSearcher.new(self)
        searcher.find_resource(name)
      end

      def merge_nested_resources(target, source)
        # Merge members
        target[:members].merge!(source[:members]) if source[:members]

        # Merge collections
        target[:collections].merge!(source[:collections]) if source[:collections]

        # Recursively merge nested resources
        if source[:resources]
          target[:resources] ||= {}
          source[:resources].each do |name, nested_resource|
            if target[:resources][name]
              merge_nested_resources(target[:resources][name], nested_resource)
            else
              target[:resources][name] = nested_resource
            end
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
                              [:show, :create, :update, :destroy]  # No :index for singular
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
