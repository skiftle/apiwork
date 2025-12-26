# frozen_string_literal: true

module Apiwork
  class Registry
    class << self
      def store
        @store ||= Concurrent::Map.new
      end

      def find(key)
        store[normalize_key(key)]
      end

      def fetch(key)
        k = normalize_key(key)
        store.fetch(k) { raise KeyError.new("#{registry_name} :#{k} not found. Available: #{keys.join(', ')}", key: k, receiver: store) }
      end

      def registered?(key)
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
        @store = Concurrent::Map.new
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
