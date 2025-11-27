# frozen_string_literal: true

module Apiwork
  module Configuration
    class Builder
      def initialize(configurable_class, storage)
        @configurable_class = configurable_class
        @storage = storage
      end

      def method_missing(name, value = nil, &block)
        option = @configurable_class.options[name]
        raise ConfigurationError, "Unknown option: #{name}" unless option

        if block && option.nested?
          @storage[name] ||= {}
          nested = NestedBuilder.new(option, @storage[name])
          nested.instance_eval(&block)
        else
          option.validate!(value)
          @storage[name] = value
        end
      end

      def respond_to_missing?(name, include_private = false)
        @configurable_class.options.key?(name) || super
      end
    end
  end
end
