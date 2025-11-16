# frozen_string_literal: true

module Apiwork
  module Contract
    class Parser
      # Deserialization logic for Parser
      #
      # Applies attribute-level deserialization transformers to input data:
      # - Applies transformers defined on schema attributes (e.g., blank_to_nil)
      # - Handles nested objects recursively
      # - Handles arrays with nested objects
      # - Only applies to params with attribute_definition reference
      #
      # Example:
      #   attribute :name, empty: true
      #   # Adds deserialize: [:blank_to_nil] which converts "" → nil
      #
      module Deserialization
        extend ActiveSupport::Concern

        private

        # Apply deserialization transformers to input data
        def apply_deserialize_transformers(data)
          return data unless data.is_a?(Hash)
          return data unless definition

          deserialize_hash(data, definition)
        end

        # Recursively apply transformers to hash based on definition
        def deserialize_hash(hash, definition)
          deserialized = hash.dup

          definition.params.each do |name, param_options|
            next unless deserialized.key?(name)

            value = deserialized[name]
            deserialized[name] = deserialize_value(value, param_options)
          end

          deserialized
        end

        # Apply transformers to single value based on param options
        def deserialize_value(value, param_options)
          # First apply attribute-level transformers (if this param came from a schema attribute)
          transformed_value = if param_options[:attribute_definition]
                                param_options[:attribute_definition].deserialize(value)
                              else
                                value
                              end

          # Then handle nested structures recursively
          # Handle arrays
          return deserialize_array(transformed_value, param_options) if param_options[:type] == :array && transformed_value.is_a?(Array)

          # Handle shape objects (nested params)
          return deserialize_hash(transformed_value, param_options[:shape]) if param_options[:shape] && transformed_value.is_a?(Hash)

          transformed_value
        end

        # Apply transformers to array elements
        def deserialize_array(array, param_options)
          array.map do |item|
            if param_options[:shape] && item.is_a?(Hash)
              # Array of objects with shape definition
              deserialize_hash(item, param_options[:shape])
            else
              # Array of primitives or objects without shape - no transformation
              item
            end
          end
        end
      end
    end
  end
end
