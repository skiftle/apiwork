# frozen_string_literal: true

module Apiwork
  module Generation
    module Generators
      # Base class for all spec generators
      #
      # Provides utilities for accessing API introspection data and transforming keys.
      # Subclasses implement specific spec formats (OpenAPI, Zod, TypeScript).
      #
      # @example
      #   class MyGenerator < Base
      #     def generate
      #       # Use data, types, enums, resources
      #       # Use transform_key for key transformation
      #     end
      #   end
      class Base
        attr_reader :path, :data, :options

        class << self
          # Generate spec using class-level API
          #
          # @param path [String] API mount path (e.g., '/api/v1')
          # @param options [Hash] Generator-specific options
          # @return [String] Generated spec content
          def generate(path:, **options)
            new(path, **options).generate
          end

          # Define generator name for registration
          # If not set, defaults to class name underscored
          #
          # @param name [Symbol, nil] Generator name
          # @return [Symbol] Generator name
          def generator_name(name = nil)
            @generator_name = name if name
            @generator_name || self.name.demodulize.underscore.to_sym
          end

          # Define content type for HTTP response
          #
          # @param type [String, nil] Content type
          # @return [String] Content type
          def content_type(type = nil)
            @content_type = type if type
            @content_type || 'application/json'
          end

          # Define file extension for file export
          # Must be implemented by subclasses
          #
          # @return [String] File extension with dot (e.g., '.json', '.ts')
          def file_extension
            raise NotImplementedError, "#{self} must implement .file_extension"
          end

          # Define default options for this generator
          # Subclasses can override to provide generator-specific defaults
          #
          # @return [Hash] Default options hash
          def default_options
            {}
          end
        end

        # Initialize generator
        #
        # @param path [String] API mount path
        # @param options [Hash] Generator options including :key_transform and :version
        # @option options [Symbol] :key_transform (:none) Key transformation strategy
        # @option options [String] :version Generator-specific version
        def initialize(path, **options)
          @path = path
          @options = self.class.default_options.merge(options)
          @options[:key_transform] ||= :none
          load_data
        end

        # Load data from API introspection
        def load_data
          api = Apiwork::API.find(path)
          raise "API not found at path: #{path}" unless api

          @data = api.introspect
        end

        # Must be implemented by subclasses
        #
        # @return [String] Generated spec content
        def generate
          raise NotImplementedError, "#{self.class} must implement #generate"
        end

        protected

        # Get key transformation strategy from options
        #
        # @return [Symbol] Key transformation strategy
        def key_transform
          @options[:key_transform]
        end

        # Get generator version from options
        #
        # @return [String, nil] Generator version
        def version
          @options[:version]
        end

        # Transform key using Transform::Case
        # Preserves leading underscores for special fields like _and, _or, _not
        #
        # @param key [String, Symbol] Key to transform
        # @param strategy [Symbol, nil] Transformation strategy (defaults to key_transform)
        # @return [String] Transformed key
        def transform_key(key, strategy = nil)
          key_str = key.to_s

          # Preserve leading underscores (e.g., _and, _or, _not)
          if key_str.start_with?('_')
            underscore_prefix = key_str.match(/^_+/)[0]
            key_without_prefix = key_str[underscore_prefix.length..]
            transformed = Transform::Case.string(key_without_prefix, strategy || key_transform)
            "#{underscore_prefix}#{transformed}"
          else
            Transform::Case.string(key_str, strategy || key_transform)
          end
        end

        # Get API metadata (title, version, description)
        #
        # @return [Hash, nil] API metadata
        def metadata
          @data[:metadata]
        end

        # Get all custom types
        #
        # @return [Hash] Types hash from introspection
        def types
          @data[:types] || {}
        end

        # Get all enums
        #
        # @return [Hash] Enums hash from introspection
        def enums
          @data[:enums] || {}
        end

        # Get all resources
        #
        # @return [Hash] Resources hash from introspection
        def resources
          @data[:resources] || {}
        end

        # Get global error codes
        #
        # @return [Array] Error codes array
        def error_codes
          @data[:error_codes] || []
        end

        # Iterate over all resources recursively
        #
        # @yield [resource_name, resource_data, parent_path] Yields each resource
        def each_resource(&block)
          iterate_resources(resources, &block)
        end

        # Iterate over all actions in a resource
        #
        # @param resource_data [Hash] Resource data hash
        # @yield [action_name, action_data] Yields each action
        def each_action(resource_data, &block)
          return unless resource_data[:actions]

          resource_data[:actions].each(&block)
        end

        # Determine HTTP method for standard action
        #
        # @param action [Symbol] Action name
        # @return [String] HTTP method (GET, POST, PATCH, DELETE)
        def http_method_for_action(action)
          case action.to_sym
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

        # Build full path for a resource
        #
        # @param resource_data [Hash] Resource data hash
        # @param parent_path [String, nil] Parent path prefix
        # @return [String] Full resource path
        def build_full_resource_path(resource_data, parent_path = nil)
          if parent_path
            "#{parent_path}/#{resource_data[:path]}"
          else
            resource_data[:path]
          end
        end

        # Build full path for an action
        #
        # @param resource_data [Hash] Resource data hash
        # @param action_data [Hash] Action data hash
        # @param parent_path [String, nil] Parent path prefix
        # @return [String] Full action path
        def build_full_action_path(resource_data, action_data, parent_path = nil)
          resource_path = build_full_resource_path(resource_data, parent_path)
          "#{resource_path}#{action_data[:path]}"
        end

        private

        # Recursively iterate over resources including nested ones
        #
        # @param resources_hash [Hash] Resources to iterate
        # @param parent_path [String, nil] Parent path prefix
        # @yield [resource_name, resource_data, parent_path] Yields each resource
        def iterate_resources(resources_hash, parent_path = nil, &block)
          resources_hash.each do |resource_name, resource_data|
            yield(resource_name, resource_data, parent_path)

            # Recurse into nested resources
            if resource_data[:resources]
              current_path = build_full_resource_path(resource_data, parent_path)
              iterate_resources(resource_data[:resources], current_path, &block)
            end
          end
        end
      end
    end
  end
end
