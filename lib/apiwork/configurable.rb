# frozen_string_literal: true

module Apiwork
  module Configurable
    extend ActiveSupport::Concern

    def self.define(extends: nil, &block)
      Class.new do
        include Configurable

        self.options = extends.options.dup if extends.respond_to?(:options)

        class_eval(&block) if block
      end
    end

    included do
      class_attribute :options, default: {}, instance_predicate: false
    end

    # @!method option(name, type:, default: nil, enum: nil, &block)
    #   @!scope class
    #   @api public
    #   Defines a configuration option.
    #
    #   For nested options, use `type: :hash` with a block. Inside the block,
    #   call `option` to define child options.
    #
    #   @param name [Symbol] option name
    #   @param type [Symbol] [:symbol, :string, :integer, :boolean, :hash]
    #   @param default [Object, nil] (nil) default value
    #   @param enum [Array, nil] (nil) allowed values
    #   @yield block evaluated in {Configuration::Option} context (for :hash type)
    #   @return [void]
    #   @see Configuration::Option
    #
    #   @example Symbol option
    #     option :locale, type: :symbol, default: :en
    #
    #   @example String option with enum
    #     option :version, type: :string, default: '5', enum: %w[4 5]
    #
    #   @example Nested options
    #     option :pagination, type: :hash do
    #       option :strategy, type: :symbol, default: :offset, enum: %i[offset cursor]
    #       option :default_size, type: :integer, default: 20
    #       option :max_size, type: :integer, default: 100
    #     end

    class_methods do
      def inherited(subclass)
        super
        subclass.options = options.dup
      end

      def option(name, default: nil, enum: nil, type:, &block)
        options[name] = Configuration::Option.new(name, type, default:, enum:, &block)
      end

      def default_options
        options.transform_values(&:effective_default).compact
      end
    end
  end
end
