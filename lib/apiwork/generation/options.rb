# frozen_string_literal: true

module Apiwork
  module Generation
    # Shared options parsing and validation for schema generation
    #
    # Used by both controller (HTTP params) and Schema.write (ENV vars)
    class Options
      VALID_KEY_TRANSFORMS = %i[camelize_lower camelize_upper underscore dasherize none].freeze

      # Build options hash from raw values
      #
      # @param key_transform [String, Symbol, nil] Key transform option
      # @return [Hash] Validated options hash with symbolized keys
      def self.build(key_transform: nil, **_ignored)
        {
          key_transform: parse_key_transform(key_transform)
        }.compact
      end

      # Parse and validate key_transform value
      #
      # @param value [String, Symbol, nil] Raw key transform value
      # @return [Symbol, nil] Validated key transform or nil
      # @raise [ArgumentError] if value is invalid
      def self.parse_key_transform(value)
        return nil if value.blank?

        transform = value.to_sym

        unless VALID_KEY_TRANSFORMS.include?(transform)
          raise ArgumentError,
                "Invalid key_transform: #{transform.inspect}. " \
                "Valid values: #{VALID_KEY_TRANSFORMS.join(', ')}"
        end

        transform
      end

      private_class_method :parse_key_transform
    end
  end
end
