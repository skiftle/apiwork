# frozen_string_literal: true

module Apiwork
  module Contract
    class RequestParser
      class Deserializer
        def self.deserialize(shape, hash)
          new(shape).deserialize(hash)
        end

        def initialize(shape)
          @shape = shape
        end

        def deserialize(hash)
          deserialized = hash.dup

          shape.params.each do |name, param_options|
            next unless deserialized.key?(name)

            deserialized[name] = deserialize_value(deserialized[name], param_options)
          end

          deserialized
        end

        private

        attr_reader :shape

        def deserialize_value(value, param_options)
          representation_class = resolve_representation_class(param_options)
          return representation_class.deserialize(value) if representation_class

          attribute = resolve_attribute(param_options)
          transformed_value = attribute ? attribute.decode(value) : value

          return deserialize_array(transformed_value, param_options) if param_options[:type] == :array && transformed_value.is_a?(Array)

          return Deserializer.new(param_options[:shape]).deserialize(transformed_value) if param_options[:shape] && transformed_value.is_a?(Hash)

          transformed_value
        end

        def deserialize_array(array, param_options)
          array.map do |item|
            if param_options[:shape] && item.is_a?(Hash)
              Deserializer.new(param_options[:shape]).deserialize(item)
            else
              item
            end
          end
        end

        def resolve_attribute(param_options)
          param_name = param_options[:name]
          return nil unless param_name

          representation_class = shape.contract_class.representation_class
          return nil unless representation_class

          representation_class.attributes[param_name]
        end

        def resolve_representation_class(param_options)
          type_name = param_options[:type]
          return nil unless type_name.is_a?(Symbol)

          shape.contract_class.api_class.type_registry.representation_class(type_name, scope: shape.contract_class)
        end
      end
    end
  end
end
