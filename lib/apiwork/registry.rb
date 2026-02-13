# frozen_string_literal: true

module Apiwork
  class Registry
    class << self
      def store
        @store ||= {}
      end

      def find(key)
        store[normalize_key(key)]
      end

      def find!(key)
        normalized_key = normalize_key(key)
        store.fetch(normalized_key) do
          raise KeyError.new(
            "#{registry_name} :#{normalized_key} not found. Available: #{keys.join(', ')}",
            key: normalized_key,
            receiver: store,
          )
        end
      end

      def exists?(key)
        store.key?(normalize_key(key))
      end

      def keys
        store.keys
      end

      def values
        store.values
      end

      def delete(key)
        store.delete(normalize_key(key))
      end

      def clear!
        @store = {}
      end

      private

      def normalize_key(key)
        key.to_sym
      end

      def registry_name
        name.demodulize
      end
    end
  end
end
