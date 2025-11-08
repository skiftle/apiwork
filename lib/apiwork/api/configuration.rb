# frozen_string_literal: true

module Apiwork
  module API
    # Configuration DSL for API classes
    #
    # Provides: configure_from_path, schema, mount_at
    module Configuration
      # Configure API from path - path is the source of truth
      #
      # Derives everything from path:
      # - Mount path (where routes are exposed)
      # - Namespaces (Ruby module structure)
      # - Identifier (for lookups)
      #
      # @param path [String] The path (e.g., '/api/v1', '/', '/admin')
      # @example
      #   configure_from_path('/api/v1')  # => Api::V1 controllers, mounted at /api/v1
      #   configure_from_path('/')        # => Root controllers, mounted at /
      def configure_from_path(path)
        @mount_path = path
        @schemas = {}

        # Parse path to namespaces array
        @namespaces_parts = path_to_namespaces(path)

        # Create metadata with path as source
        @metadata = Metadata.new(path)
        @recorder = Recorder.new(@metadata, @namespaces_parts)

        # Register in Registry
        Registry.register(self)
      end

      # Override mount path if needed
      #
      # @param path [String] Custom mount path
      # @example
      #   configure_from_path('/api/v1')
      #   mount_at '/v1'  # Mount at /v1 instead of /api/v1
      def mount_at(path)
        @mount_path = path
      end

      # Expose a schema endpoint
      #
      # @param type [Symbol] Schema type to expose (:openapi, :transport, :zod)
      # @param path [String] Optional custom path for the schema endpoint
      # @example
      #   schema :openapi
      #   schema :transport
      #   schema :openapi, path: '/openapi.json'
      def schema(type, path: nil)
        # Validate that type is registered
        unless Generation::Registry.registered?(type)
          available = Generation::Registry.all.join(', ')
          raise ConfigurationError,
                "Unknown schema generator: :#{type}. " \
                "Available generators: #{available}"
        end

        # Initialize schemas hash if needed
        @schemas ||= {}

        # Default path if not specified
        path ||= "/.schema/#{type}"

        # Add to schemas hash
        @schemas[type] = path
      end

      # Check if any schemas are exposed
      #
      # @return [Boolean]
      def schemas?
        @schemas&.any?
      end

      # Set global error codes for all endpoints in this API
      #
      # @param codes [Array<Integer>] HTTP status codes that can be returned
      # @example
      #   error_codes 400, 500, 503
      def error_codes(*codes)
        @metadata.error_codes = codes.flatten.map(&:to_i).uniq.sort
      end

      private

      # Convert path to namespaces array
      #
      # @param path [String] The path
      # @return [Array<Symbol>] Namespaces array
      # @example
      #   path_to_namespaces('/api/v1')  # => [:api, :v1]
      #   path_to_namespaces('/')        # => [:root]
      #   path_to_namespaces('/admin')   # => [:admin]
      def path_to_namespaces(path)
        return [:root] if path == '/'

        path.split('/').reject(&:empty?).map(&:to_sym)
      end
    end
  end
end
