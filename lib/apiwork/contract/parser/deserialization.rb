# frozen_string_literal: true

module Apiwork
  module Contract
    class Parser
      module Deserialization
        extend ActiveSupport::Concern

        private

        def apply_deserialize_transformers(data)
          return data unless data.is_a?(Hash)
          return data unless definition

          deserialize_hash(data, definition)
        end

        def deserialize_hash(hash, definition)
          deserialized = hash.dup

          definition.params.each do |name, param_options|
            next unless deserialized.key?(name)

            value = deserialized[name]
            deserialized[name] = deserialize_value(value, param_options)
          end

          deserialized
        end

        def deserialize_value(value, param_options)
          transformed_value = if param_options[:attribute_definition]
                                param_options[:attribute_definition].decode(value)
                              else
                                value
                              end

          return deserialize_array(transformed_value, param_options) if param_options[:type] == :array && transformed_value.is_a?(Array)

          return deserialize_hash(transformed_value, param_options[:shape]) if param_options[:shape] && transformed_value.is_a?(Hash)

          transformed_value
        end

        def deserialize_array(array, param_options)
          array.map do |item|
            if param_options[:shape] && item.is_a?(Hash)
              deserialize_hash(item, param_options[:shape])
            else
              item
            end
          end
        end
      end
    end
  end
end
