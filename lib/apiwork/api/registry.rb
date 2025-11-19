# frozen_string_literal: true

require 'concurrent/map'

module Apiwork
  module API
    class Registry
      class << self
        def register(api_class)
          return unless api_class.metadata&.path

          normalized_path = normalize_path(api_class.metadata.path)
          apis[normalized_path] = api_class
        end

        def find(path)
          return nil unless path

          normalized_path = normalize_path(path)
          apis[normalized_path]
        end

        def all
          apis.values.uniq
        end

        def unregister(path)
          return unless path

          normalized_path = normalize_path(path)
          apis.delete(normalized_path)
        end

        def clear!
          @apis = Concurrent::Map.new
        end

        private

        def normalize_path(path)
          return 'root' if path == '/'

          path.sub(%r{^/}, '').downcase
        end

        def apis
          @apis ||= Concurrent::Map.new
        end
      end
    end
  end
end
