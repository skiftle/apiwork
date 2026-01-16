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

    def method_missing(name, *args, &block)
      option = @options[name]
      raise ConfigurationError, "Unknown option: #{name}" unless option

      if args.empty? && !block
        stored = @storage[name]

        if option.nested?
          nested_storage = stored || {}
          return Configuration.new(option, nested_storage)
        end

        return stored.nil? ? option.default : stored
      end

      value = args.first
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

    def merge(hash)
      Configuration.new(@options, @storage.deep_merge(hash))
    end

    def dig(*keys)
      keys.compact.reduce(self) { |config, key| config.public_send(key) }
    end

    private

    def extract_options(source)
      return source if source.is_a?(Hash)

      source.respond_to?(:options) ? source.options : source.children
    end
  end
end
