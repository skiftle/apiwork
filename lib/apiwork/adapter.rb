# frozen_string_literal: true

module Apiwork
  module Adapter
    class << self
      def register(name, adapter_class)
        registry[name.to_sym] = adapter_class
      end

      def resolve(name)
        registry[name.to_sym] || (raise ArgumentError, "Unknown adapter: #{name}")
      end

      def registry
        @registry ||= { apiwork: Adapter::Apiwork }
      end

      def reset!
        @registry = nil
        Contract::SchemaRegistry.clear!
      end
    end
  end
end
