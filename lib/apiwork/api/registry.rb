# frozen_string_literal: true

module Apiwork
  module API
    # Maintains a global registry of all defined API classes
    #
    # Path is the primary key for lookups
    #
    # @example
    #   Registry.register(api_class)
    #   Registry.find('/api/v1')
    #   Registry.find('api/v1')
    #   Registry.find('/')
    #   Registry.all_classes
    class Registry
      class << self
        # Register an API class in the global registry
        #
        # @param api_class [Class] The API class to register
        def register(api_class)
          # Register by class name (for legacy/debug)
          apis[api_class.name] = api_class if api_class.name

          # Register by path (primary key)
          if api_class.metadata&.path
            normalized_path = normalize_path(api_class.metadata.path)
            apis_by_path[normalized_path] = api_class
          end
        end

        # Find an API class by path or namespaces (backward compatible)
        #
        # @param path_or_namespaces [String, Array] The path or namespaces to look up
        #   - "/api/v1" (path with leading slash)
        #   - "api/v1" (path without leading slash)
        #   - "/" (root path)
        #   - [:api, :v1] (namespaces array - backward compatible)
        # @return [Class, nil] The found API class or nil
        def find(path_or_namespaces)
          return nil unless path_or_namespaces

          # Convert to path if array (backward compatibility)
          path = if path_or_namespaces.is_a?(Array)
                   # [:api, :v1] -> "api/v1"
                   path_or_namespaces.map(&:to_s).join('/')
                 else
                   path_or_namespaces
                 end

          # Normalize path for lookup
          normalized_path = normalize_path(path)

          # Lookup by path
          apis_by_path[normalized_path]
        end

        # Get all registered API classes
        #
        # @return [Array<Class>] All registered API classes
        def all_classes
          # Use apis_by_path since anonymous classes from .draw don't have names
          apis_by_path.values.uniq
        end

        # Clear all registered APIs (useful for testing)
        def clear
          apis.clear
          apis_by_path.clear
        end

        private

        # Normalize path for consistent lookups
        #
        # @param path [String] The path to normalize
        # @return [String] Normalized path (lowercase, no leading slash, 'root' for '/')
        def normalize_path(path)
          return 'root' if path == '/'

          path.sub(%r{^/}, '').downcase
        end

        # Internal storage for APIs by class name
        def apis
          @apis ||= {}
        end

        # Internal storage for APIs by path
        def apis_by_path
          @apis_by_path ||= {}
        end
      end
    end
  end
end
