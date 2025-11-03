# frozen_string_literal: true

module Apiwork
  module Resource
    module Serialization
      extend ActiveSupport::Concern

      class_methods do
        def serialize(object_or_collection, context = {})
          if object_or_collection.is_a?(ActiveRecord::Relation) && auto_include_associations
            object_or_collection = apply_includes(object_or_collection)
          end

          if object_or_collection.respond_to?(:each)
            object_or_collection.map { |obj| new(obj, context).as_json }
          else
            new(object_or_collection, context).as_json
          end
        rescue StandardError => e
          raise Apiwork::SerializationError, "Serialization error for #{model_class.name}: #{e.message}"
        end
      end

      def as_json
        serialized_attributes = {}

        self.class.attribute_definitions.each do |attribute, definition|
          value = respond_to?(attribute) ? public_send(attribute) : object.public_send(attribute)
          value = definition.serialize(value)
          serialized_attributes[attribute] = value
        end

        self.class.association_definitions.each do |association, definition|
          serialized_attributes[association] = serialize_association(association, definition)
        end

        Transform::Case.hash(serialized_attributes, self.class.serialize_key_transform)
      end

      private

      def serialize_association(name, definition)
        associated = object.public_send(name)
        return nil if associated.nil?

        resource_class = definition.resource_class || detect_association_resource(name)
        return nil unless resource_class

        # Constantize if string
        resource_class = resource_class.constantize if resource_class.is_a?(String)

        if definition.collection?
          associated.map { |item| resource_class.new(item, context).as_json }
        else
          resource_class.new(associated, context).as_json
        end
      end

      def detect_association_resource(association_name)
        reflection = object.class.reflect_on_association(association_name)
        Resource::Resolver.from_association(reflection, self.class)
      end
    end
  end
end
