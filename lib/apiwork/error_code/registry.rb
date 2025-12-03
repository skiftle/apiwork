# frozen_string_literal: true

module Apiwork
  module ErrorCode
    class Registry
      class << self
        def store
          @store ||= Store.new
        end

        def register(key, status:)
          key = key.to_sym
          status = Integer(status)

          raise ArgumentError, "Status must be 400-599, got #{status}" unless (400..599).cover?(status)

          store[key] = Definition.new(key:, status:)
        end

        def fetch(key)
          key = key.to_sym
          store.fetch(key) { raise ArgumentError, "Unknown error code :#{key}. Available: #{all.join(', ')}" }
        end

        def registered?(key)
          store.key?(key.to_sym)
        end

        def all
          store.keys
        end

        def clear!
          @store = Store.new
        end
      end
    end
  end
end
