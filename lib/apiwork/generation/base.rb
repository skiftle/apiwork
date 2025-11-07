# frozen_string_literal: true

module Apiwork
  module Generation
    class Base
      attr_reader :path, :key_transform, :api_data, :component_registry, :options

      class << self
        # Generate schema using class-level API
        #
        # @param path [String] API mount path (e.g., '/api/v1')
        # @param options [Hash] Generator-specific options
        # @return [String] Generated schema content
        def generate(path, **options)
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
      end

      # Initialize generator
      #
      # @param path [String] API mount path
      # @param key_transform [Symbol] Key transformation strategy
      # @param options [Hash] Additional generator-specific options
      def initialize(path, key_transform: :camelize_lower, **options)
        @path = path
        @key_transform = key_transform
        @options = options
        load_data
      end

      # Load data from API.as_json
      def load_data
        api = Apiwork::API.find(path)
        raise "API not found at path: #{path}" unless api

        @api_data = api.as_json
        @component_registry = ComponentRegistry.new
        @component_registry.extract_components(@api_data)
      end

      # Must be implemented by subclasses
      #
      # @return [String] Generated schema content
      def generate
        raise NotImplementedError, "#{self.class} must implement #generate"
      end

      protected

      # Transform key using Transform::Case
      #
      # @param key [String, Symbol] Key to transform
      # @param strategy [Symbol, nil] Transformation strategy (defaults to @key_transform)
      # @return [String] Transformed key
      def transform_key(key, strategy = nil)
        Transform::Case.string(key, strategy || @key_transform)
      end

      # Get API metadata (title, version, description)
      #
      # @return [Hash, nil] API metadata
      def metadata
        @api_data[:metadata]
      end

      # Get all resources
      #
      # @return [Hash] Resources hash from API.as_json
      def resources
        @api_data[:resources] || {}
      end

      # Iterate over all resources recursively
      #
      # @yield [resource_name, resource_data] Yields each resource
      def each_resource(&block)
        iterate_resources(resources, &block)
      end

      # Determine HTTP method for standard action
      #
      # @param action [Symbol] Action name
      # @return [String] HTTP method (GET, POST, PATCH, DELETE)
      def http_method_for_action(action)
        case action
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

      private

      # Recursively iterate over resources including nested ones
      def iterate_resources(resources_hash, &block)
        resources_hash.each do |resource_name, resource_data|
          block.call(resource_name, resource_data)

          # Recurse into nested resources
          if resource_data[:resources]
            iterate_resources(resource_data[:resources], &block)
          end
        end
      end
    end
  end
end
