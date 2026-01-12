# frozen_string_literal: true

module Apiwork
  # @api public
  # DSL evaluator for adapter and export configuration.
  #
  # Used within configuration blocks in {Adapter::Base} and {Export::Base}.
  class Configuration
    def initialize(options_source, storage = {})
      @options = extract_options(options_source)
      @storage = storage
    end

    def method_missing(name, value = nil, &block)
      option = @options[name]
      raise ConfigurationError, "Unknown option: #{name}" unless option

      if block && option.nested?
        @storage[name] ||= {}
        Configuration.new(option, @storage[name]).instance_eval(&block)
      else
        option.validate!(value)
        @storage[name] = value
      end
    end

    def respond_to_missing?(name, include_private = false)
      @options.key?(name) || super
    end

    private

    def extract_options(source)
      source.respond_to?(:options) ? source.options : source.children
    end
  end
end
