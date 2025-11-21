# frozen_string_literal: true

module Apiwork
  module Generator
    # Options parsing and validation for generators
    # DSL only allows three key formats: underscore, camel, keep
    module Options
      module_function

      VALID_KEY_TRANSFORMS = %i[underscore camel keep].freeze

      def build(key_transform: nil, version: nil, **_ignored)
        {
          key_transform: parse_key_transform(key_transform),
          version: version&.to_s
        }.compact
      end

      def parse_key_transform(value)
        return nil if value.blank?

        transform = value.to_sym

        unless VALID_KEY_TRANSFORMS.include?(transform)
          raise ArgumentError,
                "Invalid key_transform: #{transform.inspect}. " \
                "Valid values: #{VALID_KEY_TRANSFORMS.join(', ')}"
        end

        transform
      end

      private :parse_key_transform
    end
  end
end
