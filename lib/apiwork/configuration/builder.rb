# frozen_string_literal: true

module Apiwork
  module Configuration
    # Configuration builder for DSL blocks
    # Used in API, Schema, and Contract configure blocks
    class Builder
      # Configuration settings with validation
      VALIDATED_SETTINGS = {
        output_key_format: -> { Transform::Case.valid_strategies },
        input_key_format: -> { Transform::Case.valid_strategies }
      }.freeze

      def initialize(storage)
        @storage = storage
      end

      # Set output key format strategy
      def output_key_format(value)
        validate_setting!(:output_key_format, value)
        @storage[:output_key_format] = value
      end

      # Set input key format strategy
      def input_key_format(value)
        validate_setting!(:input_key_format, value)
        @storage[:input_key_format] = value
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
