# frozen_string_literal: true

module Apiwork
  module Contract
    class Object
      class Deserializer
        class << self
          def deserialize(shape, hash)
            new(shape).deserialize(hash)
          end
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
          attribute = resolve_attribute(param_options)
          decoded_value = attribute ? attribute.decode(value) : value

          return deserialize_array(decoded_value, param_options) if param_options[:type] == :array && decoded_value.is_a?(Array)

          return Deserializer.new(param_options[:shape]).deserialize(decoded_value) if param_options[:shape] && decoded_value.is_a?(Hash)

          decoded_value
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
      end
    end
  end
end
