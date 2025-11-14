# frozen_string_literal: true

module Apiwork
  class Configuration
    attr_accessor :raise_on_invalid_fields, :default_sort, :default_page_size, :maximum_page_size,
                  :max_array_items
    attr_reader :serialize_key_transform, :deserialize_key_transform

    VALIDATED_ATTRIBUTES = {
      serialize_key_transform: -> { Transform::Case.valid_strategies },
      deserialize_key_transform: -> { Transform::Case.valid_strategies }
    }.freeze

    def initialize
      @raise_on_invalid_fields = false
      @default_sort = { id: :asc }
      @default_page_size = 20
      @maximum_page_size = 200
      @serialize_key_transform = :none
      @deserialize_key_transform = :none
      @max_array_items = 1000
    end

    VALIDATED_ATTRIBUTES.each do |attribute_name, valid_values|
      define_method(:"#{attribute_name}=") do |value|
        validate_attribute!(attribute_name, value, valid_values)
        instance_variable_set(:"@#{attribute_name}", value)
      end
    end

    private

    def validate_attribute!(attribute_name, value, valid_values)
      valid_values = valid_values.call if valid_values.is_a?(Proc)

      return if valid_values.include?(value)

      error_message = "Invalid #{attribute_name}: #{value}. Must be one of #{valid_values.join(', ')}"

      raise ConfigurationError, error_message
    end
  end
end
