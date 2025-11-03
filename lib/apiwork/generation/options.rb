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
      # @param builders [String, Boolean, nil] Include builders option
      # @return [Hash] Validated options hash with symbolized keys
      def self.build(key_transform: nil, builders: nil)
        {
          key_transform: parse_key_transform(key_transform),
          builders: parse_boolean(builders)
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

      # Parse boolean value from string or boolean
      #
      # @param value [String, Boolean, nil] Raw boolean value
      # @return [Boolean, nil] Parsed boolean or nil
      def self.parse_boolean(value)
        return nil if value.blank?

        case value.to_s.downcase
        when 'true', '1', 'yes'
          true
        when 'false', '0', 'no'
          false
        else
          nil
        end
      end

      private_class_method :parse_key_transform, :parse_boolean
    end
  end
end
