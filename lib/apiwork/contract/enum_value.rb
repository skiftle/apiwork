# frozen_string_literal: true

module Apiwork
  module Contract
    # Helper class for enum value extraction and validation
    class EnumValue
      # Extract values array from enum definition
      # Handles both inline arrays and resolved hashes from Registry
      #
      # @param enum [Array, Hash, nil] The enum definition
      # @return [Array, nil] The array of valid enum values, or nil if enum is nil
      def self.values(enum)
        return nil if enum.nil?

        enum.is_a?(Hash) ? enum[:values] : enum
      end

      # Check if value is valid for the given enum
      #
      # @param value [Object] The value to validate
      # @param enum [Array, Hash, nil] The enum definition
      # @return [Boolean] true if valid, false otherwise
      def self.valid?(value, enum)
        enum_values = values(enum)
        return true if enum_values.nil?

        enum_values.include?(value)
      end

      # Format enum values for error messages
      #
      # @param enum [Array, Hash, nil] The enum definition
      # @return [String] Comma-separated list of values
      def self.format(enum)
        enum_values = values(enum)
        return '' if enum_values.blank?

        enum_values.join(', ')
      end
    end
  end
end
