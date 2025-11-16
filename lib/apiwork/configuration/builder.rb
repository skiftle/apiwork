# frozen_string_literal: true

module Apiwork
  module Configuration
    # Configuration builder for DSL blocks
    # Used in API, Schema, and Contract configure blocks
    class Builder
      # Configuration settings with validation
      VALIDATED_SETTINGS = {
        serialize_key_transform: -> { Transform::Case.valid_strategies },
        deserialize_key_transform: -> { Transform::Case.valid_strategies }
      }.freeze

      def initialize(storage)
        @storage = storage
      end

      # Set serialize key transform strategy
      def serialize_key_transform(value)
        validate_setting!(:serialize_key_transform, value)
        @storage[:serialize_key_transform] = value
      end

      # Set deserialize key transform strategy
      def deserialize_key_transform(value)
        validate_setting!(:deserialize_key_transform, value)
        @storage[:deserialize_key_transform] = value
      end

      # Set default sort order
      def default_sort(value)
        @storage[:default_sort] = value
      end

      # Set default page size
      def default_page_size(value)
        @storage[:default_page_size] = value
      end

      # Set maximum page size
      def maximum_page_size(value)
        @storage[:maximum_page_size] = value
      end

      # Set maximum array items
      def max_array_items(value)
        @storage[:max_array_items] = value
      end

      private

      def validate_setting!(name, value)
        validator = VALIDATED_SETTINGS[name]
        return unless validator

        valid_values = validator.call
        return if valid_values.include?(value)

        raise ConfigurationError,
              "Invalid #{name}: #{value}. Must be one of #{valid_values.join(', ')}"
      end
    end
  end
end
