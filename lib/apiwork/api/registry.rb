# frozen_string_literal: true

module Apiwork
  module API
    class Registry
      class << self
        def store
          @store ||= Store.new
        end

        def register(api_class)
          return unless api_class.metadata&.path

          store[normalize_path(api_class.metadata.path)] = api_class
        end

        def find(path)
          return nil unless path

          store[normalize_path(path)]
        end

        def all
          store.values.uniq
        end

        def unregister(path)
          return unless path

          store.delete(normalize_path(path))
        end

        def clear!
          @store = Store.new
        end

        private

        def normalize_path(path)
          return 'root' if path == '/'

          path.sub(%r{^/}, '').downcase
        end
      end
    end
  end
end
