# frozen_string_literal: true

module Apiwork
  module Contract
    class RequestParser
      class Deserialization
        class << self
          def deserialize_hash(hash, shape)
            deserialized = hash.dup

            shape.params.each do |name, param_options|
              next unless deserialized.key?(name)

              deserialized[name] = deserialize_value(deserialized[name], param_options, shape)
            end

            deserialized
          end

          def deserialize_value(value, param_options, shape = nil)
            representation_class = resolve_representation_class(param_options, shape)
            return representation_class.deserialize(value) if representation_class

            attribute = resolve_attribute(param_options, shape)
            transformed_value = if attribute
                                  attribute.decode(value)
                                else
                                  value
                                end

            return deserialize_array(transformed_value, param_options, shape) if param_options[:type] == :array && transformed_value.is_a?(Array)

            return deserialize_hash(transformed_value, param_options[:shape]) if param_options[:shape] && transformed_value.is_a?(Hash)

            transformed_value
          end

          private

          def resolve_attribute(param_options, shape)
            return nil unless shape
            return nil unless shape.respond_to?(:contract_class)

            param_name = param_options[:name]
            return nil unless param_name

            contract_class = shape.contract_class
            return nil unless contract_class.representation_class

            contract_class.representation_class.attributes[param_name]
          end

          def resolve_representation_class(param_options, shape)
            return nil unless shape
            return nil unless shape.respond_to?(:contract_class)

            type_name = param_options[:type]
            return nil unless type_name.is_a?(Symbol)

            shape.contract_class.api_class.type_registry.representation_class(type_name, scope: shape.contract_class)
          end

          def deserialize_array(array, param_options, shape = nil)
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
