# frozen_string_literal: true

module Apiwork
  module Configurable
    extend ActiveSupport::Concern

    included do
      class_attribute :_options, instance_predicate: false, default: {}
    end

    class_methods do
      def options
        _options
      end

      def inherited(subclass)
        super
        subclass._options = _options.dup
      end

      def option(name, type:, default: nil, enum: nil, &block)
        _options[name] = Configuration::Option.new(name, type, default:, enum:, &block)
      end

      def default_options
        _options.transform_values(&:default).compact
      end
    end
  end
end
