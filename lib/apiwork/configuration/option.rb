# frozen_string_literal: true

module Apiwork
  class Configuration
    # @api public
    # Block context for nested configuration options.
    #
    # Used inside `option :name, type: :hash do ... end` blocks
    # in {Adapter::Base} and {Export::Base} subclasses.
    #
    # @example instance_eval style
    #   option :pagination, type: :hash do
    #     option :strategy, type: :symbol, default: :offset
    #     option :default_size, type: :integer, default: 20
    #   end
    #
    # @example yield style
    #   option :pagination, type: :hash do |option|
    #     option.option :strategy, type: :symbol, default: :offset
    #     option.option :default_size, type: :integer, default: 20
    #   end
    #
    # @see Adapter::Base
    # @see Export::Base
    # @see Configuration
    class Option
      include Validatable

      attr_reader :children,
                  :default,
                  :enum,
                  :name,
                  :type

      def initialize(name, type, children: nil, default: nil, enum: nil, &block)
        @name = name
        @type = type
        @default = default
        @enum = enum
        @children = children || {}

        return unless block && type == :hash

        block.arity.positive? ? yield(self) : instance_eval(&block)
      end

      # @api public
      # Defines a nested option.
      #
      # @param name [Symbol] the option name
      # @param type [Symbol] [:symbol, :string, :integer, :boolean, :hash]
      # @param default [Object, nil] (nil) the default value
      # @param enum [Array, nil] (nil) allowed values
      # @yield block for nested options (type: :hash)
      # @yieldparam option [Option]
      # @return [void]
      #
      # @example instance_eval style
      #   option :pagination, type: :hash do
      #     option :strategy, type: :symbol, default: :offset
      #     option :default_size, type: :integer, default: 20
      #   end
      #
      # @example yield style
      #   option :pagination, type: :hash do |option|
      #     option.option :strategy, type: :symbol, default: :offset
      #     option.option :default_size, type: :integer, default: 20
      #   end
      def option(name, default: nil, enum: nil, type:, &block)
        @children[name] = Option.new(name, type, default:, enum:, &block)
      end

      def nested?
        children.any?
      end

      def effective_default
        return default unless nested?

        children.transform_values(&:default)
      end

      def validate!(value)
        return if value.nil?

        if nested?
          raise ConfigurationError, "#{name} must be a Hash" unless value.is_a?(Hash)

          validate_children!(value)
        else
          validate_type!(value)
          validate_enum!(value) if enum
        end
      end

      def cast(value)
        return nil if value.nil?
        return value unless value.is_a?(String)

        case type
        when :symbol then value.to_sym
        when :string then value
        when :integer then value.to_i
        when :boolean then %w[true 1 yes].include?(value.downcase)
        when :hash then value
        end
      end

      private

      def validate_children!(hash)
        hash.each do |key, value|
          child = children[key]
          raise ConfigurationError, "Unknown option: #{name}.#{key}" unless child

          child.validate!(value)
        end
      end
    end
  end
end
