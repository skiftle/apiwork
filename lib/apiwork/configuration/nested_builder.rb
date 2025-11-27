# frozen_string_literal: true

module Apiwork
  module Configuration
    class NestedBuilder
      def initialize(parent_option, storage)
        @parent_option = parent_option
        @storage = storage
      end

      def method_missing(name, value = nil)
        child = @parent_option.children[name]
        raise ConfigurationError, "Unknown option: #{@parent_option.name}.#{name}" unless child

        child.validate!(value)
        @storage[name] = value
      end

      def respond_to_missing?(name, include_private = false)
        @parent_option.children.key?(name) || super
      end
    end
  end
end
