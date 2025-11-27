# frozen_string_literal: true

module Apiwork
  module Adapter
    class Configuration
      def initialize(adapter_class, storage)
        @adapter_class = adapter_class
        @storage = storage
      end

      def method_missing(name, value = nil, &block)
        option = @adapter_class.options[name]
        raise AdapterError, "Unknown option: #{name}" unless option

        option.validate!(value)
        @storage[name] = value
      end

      def respond_to_missing?(name, include_private = false)
        @adapter_class.options.key?(name) || super
      end
    end
  end
end
