# frozen_string_literal: true

module Apiwork
  module Adapter
    class Option
      attr_reader :default,
                  :enum,
                  :name,
                  :type

      def initialize(name, type:, default:, enum: nil)
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

      private

      def validate_type!(value)
        valid = case type
                when :symbol then value.is_a?(Symbol)
                when :integer then value.is_a?(Integer)
                when :hash then value.is_a?(Hash)
                end
        raise AdapterError, "#{name} must be #{type}, got #{value.class}" unless valid
      end

      def validate_enum!(value)
        return if enum.include?(value)

        raise AdapterError, "#{name} must be one of #{enum.inspect}, got #{value.inspect}"
      end
    end
  end
end
