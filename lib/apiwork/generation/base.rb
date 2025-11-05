# frozen_string_literal: true

module Apiwork
  module Generation
    class Base
      attr_reader :path, :key_transform, :resources, :routes, :documentation, :options

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

      # Load data from Inspector
      # Override needs_* methods in subclasses to control what gets loaded
      def load_data
        @resources = API::Inspector.resources(path: path) if needs_resources?
        @routes = API::Inspector.routes(path: path) if needs_routes?
        @documentation = API::Inspector.documentation(path: path) if needs_documentation?
      end

      # Override in subclasses to declare data dependencies
      def needs_resources?
        true
      end

      def needs_routes?
        false
      end

      def needs_documentation?
        false
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

      # Find resource by name
      #
      # @param name [String, Symbol] Resource name
      # @return [Hash, nil] Resource metadata
      def find_resource(name)
        return nil unless name

        @resources.find { |r| r[:name].to_s == name.to_s }
      end

      # Filter attributes by context (full, create, update, query)
      #
      # @param resource [Hash] Resource metadata
      # @param context [Symbol] Context to filter for
      # @return [Hash] Filtered attributes
      def filter_attributes(resource, context:)
        resource[:attributes].select do |_name, info|
          case context
          when :full
            true
          when :create
            writable_for_create?(info)
          when :update
            writable_for_update?(info)
          when :query
            info[:filterable] || info[:sortable]
          else
            false
          end
        end
      end

      # Check if attribute is writable for create action
      #
      # @param info [Hash] Attribute metadata
      # @return [Boolean]
      def writable_for_create?(info)
        writable_config = info[:writable]
        return false unless writable_config.is_a?(Hash)

        writable_config[:on].include?(:create)
      end

      # Check if attribute is writable for update action
      #
      # @param info [Hash] Attribute metadata
      # @return [Boolean]
      def writable_for_update?(info)
        writable_config = info[:writable]
        return false unless writable_config.is_a?(Hash)

        writable_config[:on].include?(:update)
      end

      # Build path for standard CRUD action
      #
      # @param resource_name [String, Symbol] Resource name
      # @param action [Symbol] Action name (:index, :show, :create, :update, :destroy)
      # @param metadata [Hash, nil] Resource metadata
      # @return [String] Path for action
      def build_path_for_action(resource_name, action, metadata = nil)
        base_path = build_base_path(resource_name, metadata)

        case action
        when :index, :create
          base_path
        when :show, :update, :destroy
          "#{base_path}/:id"
        else
          base_path
        end
      end

      # Build path for member action
      #
      # @param resource_name [String, Symbol] Resource name
      # @param action_name [String, Symbol] Custom action name
      # @param metadata [Hash, nil] Resource metadata
      # @return [String] Path for member action
      def build_path_for_member_action(resource_name, action_name, metadata = nil)
        base_path = build_base_path(resource_name, metadata)
        "#{base_path}/:id/#{action_name}"
      end

      # Build path for collection action
      #
      # @param resource_name [String, Symbol] Resource name
      # @param action_name [String, Symbol] Custom action name
      # @param metadata [Hash, nil] Resource metadata
      # @return [String] Path for collection action
      def build_path_for_collection_action(resource_name, action_name, metadata = nil)
        base_path = build_base_path(resource_name, metadata)
        "#{base_path}/#{action_name}"
      end

      # Build base path for resource, handling nested resources
      #
      # @param resource_name [String, Symbol] Resource name
      # @param metadata [Hash, nil] Resource metadata
      # @return [String] Base path
      def build_base_path(resource_name, metadata = nil)
        if metadata&.dig(:parent)
          parent_path = build_base_path(metadata[:parent][:name], metadata[:parent])
          parent_param = ":#{metadata[:parent][:name].to_s.singularize}_id"
          "#{parent_path}/#{parent_param}/#{resource_name}"
        else
          "/#{resource_name}"
        end
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

      # Iterate over all resources
      #
      # @yield [resource] Yields each resource
      def each_resource(&block)
        @resources.each(&block)
      end

      # Collect nested resources recursively
      #
      # @param nested_resources [Hash] Nested resources hash
      # @param collection [Array] Collection to append to
      # @return [Array] Collection with nested resources
      def collect_nested_resources(nested_resources, collection = [])
        nested_resources.each_value do |metadata|
          collection << metadata
          collect_nested_resources(metadata[:resources] || {}, collection) if metadata[:resources]
        end
        collection
      end
    end
  end
end
