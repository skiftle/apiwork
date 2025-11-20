# frozen_string_literal: true

module Apiwork
  module Configuration
    class Builder
      VALIDATED_SETTINGS = {
        output_key_format: %i[underscore camel keep],
        input_key_format: %i[underscore camel keep]
      }.freeze

      def initialize(storage)
        @storage = storage
      end

      VALIDATED_SETTINGS.each_key do |name|
        define_method(name) do |value|
          validate!(name, value)
          @storage[name] = value
        end
      end

      %i[default_sort default_page_size max_page_size max_array_items].each do |name|
        define_method(name) do |value|
          @storage[name] = value
        end
      end

      private

      def validate!(name, value)
        allowed = VALIDATED_SETTINGS[name]
        return unless allowed
        return if allowed.include?(value)

        raise ConfigurationError, "Invalid #{name}: #{value}. Allowed: #{allowed.join(', ')}"
      end
    end
  end
end
