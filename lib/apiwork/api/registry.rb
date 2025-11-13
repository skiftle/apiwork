# frozen_string_literal: true

module Apiwork
  module API
    class Registry
      class << self
        def register(api_class)
          # Register by class name (for legacy/debug)
          apis[api_class.name] = api_class if api_class.name

          # Register by path (primary key)
          return unless api_class.metadata&.path

          normalized_path = normalize_path(api_class.metadata.path)
          apis_by_path[normalized_path] = api_class
        end

        def find(path)
          return nil unless path

          # Normalize path for lookup
          normalized_path = normalize_path(path)

          # Lookup by path
          apis_by_path[normalized_path]
        end

        def all_classes
          # Use apis_by_path since anonymous classes from .draw don't have names
          apis_by_path.values.uniq
        end

        # Clear all registered APIs (useful for testing)
        def clear!
          apis.clear
          apis_by_path.clear
        end

        private

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
