# frozen_string_literal: true

module Apiwork
  module Configurable
    extend ActiveSupport::Concern

    included do
      class_attribute :options, instance_predicate: false, default: {}
    end

    # @!method option(name, type:, default: nil, enum: nil, &block)
    #   @!scope class
    #   @api public
    #   Defines a configuration option for the spec or adapter.
    #
    #   Options can be passed to `.generate` or set via environment variables.
    #
    #   @param name [Symbol] the option name
    #   @param type [Symbol] the option type (:symbol, :string, :boolean, :integer)
    #   @param default [Object, nil] default value if not provided
    #   @param enum [Array, nil] allowed values
    #   @yield block for nested options
    #   @return [void]
    #
    #   @example Simple option
    #     option :locale, type: :symbol, default: :en
    #
    #   @example Option with enum
    #     option :format, type: :symbol, enum: [:json, :yaml]

    class_methods do
      def inherited(subclass)
        super
        subclass.options = options.dup
      end

      def option(name, default: nil, enum: nil, type:, &block)
        options[name] = Configuration::Option.new(name, type, default:, enum:, &block)
      end

      def default_options
        options.transform_values(&:default).compact
      end
    end
  end
end
