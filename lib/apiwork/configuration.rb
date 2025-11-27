# frozen_string_literal: true

module Apiwork
  class Configuration
    def initialize(configurable_class, storage)
      @configurable_class = configurable_class
      @storage = storage
    end

    def method_missing(name, value = nil, &block)
      option = @configurable_class.options[name]
      raise ConfigurationError, "Unknown option: #{name}" unless option

      if block && option.nested?
        @storage[name] ||= {}
        nested_config = NestedConfiguration.new(option, @storage[name])
        nested_config.instance_eval(&block)
      else
        option.validate!(value)
        @storage[name] = value
      end
    end

    def respond_to_missing?(name, include_private = false)
      @configurable_class.options.key?(name) || super
    end
  end

  class NestedConfiguration
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
