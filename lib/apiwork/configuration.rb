# frozen_string_literal: true

module Apiwork
  class Configuration
    attr_accessor :raise_on_invalid_fields, :default_sort, :default_page_size, :maximum_page_size,
                  :max_array_items
    attr_reader :serialize_key_transform, :deserialize_key_transform, :auto_include_associations, :error_handling_mode

    VALID_BOOLEAN_VALUES = [true, false].freeze
    VALID_ERROR_HANDLING_MODES = %i[raise log silent].freeze

    VALIDATED_ATTRIBUTES = {
      serialize_key_transform: -> { Transform::Case.valid_strategies },
      deserialize_key_transform: -> { Transform::Case.valid_strategies },
      auto_include_associations: VALID_BOOLEAN_VALUES,
      error_handling_mode: VALID_ERROR_HANDLING_MODES
    }.freeze

    def initialize
      @raise_on_invalid_fields = false
      @default_sort = { id: :asc }
      @default_page_size = 20
      @maximum_page_size = 200
      @serialize_key_transform = :none
      @deserialize_key_transform = :none
      @auto_include_associations = false

      @error_handling_mode = :raise
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

      error_message = if valid_values == VALID_BOOLEAN_VALUES
                        "Invalid #{attribute_name}: #{value}. Must be true or false"
                      else
                        "Invalid #{attribute_name}: #{value}. Must be one of #{valid_values.join(', ')}"
                      end

      raise ConfigurationError, error_message
    end
  end
end
