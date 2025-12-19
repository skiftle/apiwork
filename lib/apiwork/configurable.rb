# frozen_string_literal: true

module Apiwork
  # @api private
  module Configurable
    extend ActiveSupport::Concern

    included do
      class_attribute :options, instance_predicate: false, default: {}
    end

    class_methods do
      def inherited(subclass)
        super
        subclass.options = options.dup
      end

      def option(name, type:, default: nil, enum: nil, &block)
        options[name] = Configuration::Option.new(name, type, default:, enum:, &block)
      end

      def default_options
        options.transform_values(&:default).compact
      end
    end
  end
end
