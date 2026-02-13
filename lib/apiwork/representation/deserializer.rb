# frozen_string_literal: true

module Apiwork
  module Representation
    class Deserializer
      def initialize(representation_class)
        @representation_class = representation_class
      end

      def deserialize(payload)
        if payload.is_a?(Array)
          payload.map { |hash| deserialize_hash(hash) }
        else
          deserialize_hash(payload)
        end
      end

      def deserialize_hash(hash)
        return hash unless hash.is_a?(Hash)

        result = hash.dup

        transform_type_columns(result)

        @representation_class.attributes.each do |name, attribute|
          next unless result.key?(name)

          result[name] = attribute.decode(result[name])
        end

        @representation_class.associations.each do |name, association|
          next unless result.key?(name)

          nested_representation_class = association.representation_class
          next unless nested_representation_class

          value = result[name]
          result[name] = if association.collection? && value.is_a?(Array)
                           value.map { |item| nested_representation_class.deserialize(item) }
                         elsif value.is_a?(Hash)
                           nested_representation_class.deserialize(value)
                         else
                           value
                         end
        end

        result
      end

      private

      def transform_type_columns(hash)
        transform_sti_type(hash)
        transform_polymorphic_types(hash)
      end

      def transform_sti_type(hash)
        inheritance_config = @representation_class.subclass? ? @representation_class.superclass.inheritance : @representation_class.inheritance
        return unless inheritance_config&.transform?

        column = inheritance_config.column
        return unless hash.key?(column)

        api_value = hash[column]
        db_value = inheritance_config.mapping[api_value]
        hash[column] = db_value if db_value
      end

      def transform_polymorphic_types(hash)
        @representation_class.attributes.each_key do |name|
          next unless hash.key?(name)

          association = @representation_class.polymorphic_association_for_type_column(name)
          next unless association

          api_value = hash[name]
          next unless api_value.is_a?(String)

          poly_representation = association.polymorphic.find do |rep|
            rep.polymorphic_name == api_value
          end
          next unless poly_representation

          hash[name] = poly_representation.model_class.polymorphic_name
        end
      end
    end
  end
end
