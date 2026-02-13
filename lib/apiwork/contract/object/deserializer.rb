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

          @shape.params.each do |name, param_options|
            next unless deserialized.key?(name)

            value = deserialized[name]

            deserialized[name] = deserialize_value(value, param_options)
          end

          deserialized
        end

        private

        def deserialize_value(value, param_options)
          if param_options[:union] && value.is_a?(Hash)
            deserialize_union(value, param_options[:union])
          elsif param_options[:shape] && value.is_a?(Hash)
            deserialize_shape(value, param_options[:shape])
          elsif param_options[:type] == :array && value.is_a?(Array)
            deserialize_array(value, param_options)
          else
            value
          end
        end

        def deserialize_shape(hash, nested_shape)
          representation_class = nested_shape.contract_class.representation_class
          return representation_class.deserialize(hash) if representation_class && nested_shape.params.none? { |_, options| options[:union] }

          Deserializer.new(nested_shape).deserialize(hash)
        end

        def deserialize_union(hash, union)
          variant = resolve_variant(hash, union)
          return hash unless variant

          if variant[:shape]
            representation_class = variant[:shape].contract_class.representation_class
            return representation_class.deserialize(hash) if representation_class

            Deserializer.new(variant[:shape]).deserialize(hash)
          elsif variant[:custom_type]
            deserialize_custom_type(hash, variant[:custom_type])
          else
            hash
          end
        end

        def resolve_variant(hash, union)
          discriminator = union.discriminator
          return union.variants.first unless discriminator

          tag = hash[discriminator]
          union.variants.find { |v| v[:tag].to_s == tag.to_s }
        end

        def deserialize_custom_type(hash, type_name)
          type_definition = @shape.contract_class.resolve_custom_type(type_name)
          return hash unless type_definition

          representation_class = (type_definition.scope || @shape.contract_class).representation_class

          return representation_class.deserialize(hash) if representation_class

          hash
        end

        def deserialize_array(array, param_options)
          array.map do |item|
            next item unless item.is_a?(Hash)

            if param_options[:shape]
              Deserializer.new(param_options[:shape]).deserialize(item)
            else
              item
            end
          end
        end
      end
    end
  end
end
