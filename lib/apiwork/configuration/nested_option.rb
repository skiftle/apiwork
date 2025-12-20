# frozen_string_literal: true

module Apiwork
  module Configuration
    class NestedOption
      include Validatable

      attr_reader :default,
                  :enum,
                  :name,
                  :type

      def initialize(name, type, default, enum: nil)
        @name = name
        @type = type
        @default = default
        @enum = enum
      end

      def validate!(value)
        return if value.nil?

        validate_type!(value)
        validate_enum!(value) if enum
      end
    end
  end
end
