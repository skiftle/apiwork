# frozen_string_literal: true

module Apiwork
  module Contract
    class RequestParser
      class Deserialization
        class << self
          def deserialize_hash(hash, definition)
            deserialized = hash.dup

            definition.params.each do |name, param_options|
              next unless deserialized.key?(name)

              deserialized[name] = deserialize_value(deserialized[name], param_options, definition)
            end

            deserialized
          end

          def deserialize_value(value, param_options, definition = nil)
            schema_class = resolve_schema_class(param_options, definition)
            return schema_class.deserialize(value) if schema_class

            attribute_definition = lookup_attribute_definition(param_options, definition)
            transformed_value = if attribute_definition
                                  attribute_definition.decode(value)
                                else
                                  value
                                end

            return deserialize_array(transformed_value, param_options, definition) if param_options[:type] == :array && transformed_value.is_a?(Array)

            return deserialize_hash(transformed_value, param_options[:shape]) if param_options[:shape] && transformed_value.is_a?(Hash)

            transformed_value
          end

          private

          def lookup_attribute_definition(param_options, definition)
            return nil unless definition

            param_name = param_options[:name]
            return nil unless param_name

            contract_class = definition.contract_class
            return nil unless contract_class.schema_class

            contract_class.schema_class.attribute_definitions[param_name]
          end

          def resolve_schema_class(param_options, definition)
            return nil unless definition

            type_name = param_options[:type]
            return nil unless type_name.is_a?(Symbol)

            definition.contract_class.api_class.type_registry.schema_class(type_name, scope: definition.contract_class)
          end

          def deserialize_array(array, param_options, definition = nil)
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
end
