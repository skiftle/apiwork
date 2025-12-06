# frozen_string_literal: true

module Apiwork
  module Configurable
    extend ActiveSupport::Concern

    class_methods do
      def options
        @options ||= {}
      end

      def inherited(subclass)
        super
        subclass.instance_variable_set(:@options, options.dup)
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
