# frozen_string_literal: true

module Apiwork
  module Configurable
    extend ActiveSupport::Concern

    included do
      class_attribute :options, default: {}, instance_predicate: false
    end

    # @!method option(name, type:, default: nil, enum: nil, &block)
    #   @!scope class
    #   @api public
    #   Defines a configuration option.
    #
    #   @param name [Symbol]
    #   @param type [Symbol] :symbol, :string, :integer, :boolean, or :hash
    #   @param default [Object, nil]
    #   @param enum [Array, nil]
    #   @yield block evaluated in {Configuration::Option} context (for :hash type)
    #
    #   @example Symbol option
    #     option :locale, type: :symbol, default: :en
    #
    #   @example Symbol option with enum
    #     option :strategy, type: :symbol, default: :offset, enum: %i[offset cursor]
    #
    #   @example String option
    #     option :version, type: :string, default: '1.0'
    #
    #   @example Integer option
    #     option :max_size, type: :integer, default: 100
    #
    #   @example Boolean option
    #     option :verbose, type: :boolean, default: false
    #
    #   @example Nested hash option
    #     option :pagination, type: :hash do
    #       option :strategy, type: :symbol, default: :offset
    #       option :default_size, type: :integer, default: 20
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
        options.transform_values(&:resolved_default).compact
      end
    end
  end
end
