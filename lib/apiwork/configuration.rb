# frozen_string_literal: true

module Apiwork
  # @api public
  # Typed access to configuration values with automatic defaults.
  #
  # @see API::Base#adapter_config
  # @see Representation::Base.adapter_config
  #
  # @example Reading values
  #   config.pagination.default_size  # => 20
  #   config.pagination.strategy      # => :offset
  #
  # @example Using dig for dynamic access
  #   config.dig(:pagination, :default_size)  # => 20
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

    # @api public
    # Accesses nested configuration values by key path.
    #
    # @param keys [Symbol] one or more keys to traverse
    #
    # @example
    #   config.dig(:pagination)             # => #<Apiwork::Configuration:...>
    #   config.dig(:pagination, :strategy)  # => :offset
    def dig(*keys)
      keys.compact.reduce(self) { |config, key| config.public_send(key) }
    end

    # @api public
    # Converts the configuration to a hash.
    #
    # @return [Hash]
    #
    # @example
    #   config.to_h  # => { pagination: { strategy: :offset, default_size: 20 } }
    def to_h
      @options.each_with_object({}) do |(name, option), result|
        if option.nested?
          result[name] = Configuration.new(option, @storage[name] || {}).to_h
        else
          stored = @storage[name]
          result[name] = stored.nil? ? option.default : stored
        end
      end
    end

    private

    def extract_options(source)
      return source if source.is_a?(Hash)

      source.respond_to?(:options) ? source.options : source.children
    end
  end
end
