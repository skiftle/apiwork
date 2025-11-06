# frozen_string_literal: true

module Apiwork
  module Schema
    module Serialization
      extend ActiveSupport::Concern

      class_methods do
        def serialize(object_or_collection, context: {}, includes: nil)
          # Note: ActiveRecord::Relation handling is done by Model::Plugin when active

          if object_or_collection.respond_to?(:each)
            object_or_collection.map { |obj| new(obj, context: context, includes: includes).as_json }
          else
            new(object_or_collection, context: context, includes: includes).as_json
          end
        rescue StandardError => e
          schema_name = respond_to?(:name) ? name : 'Schema'
          raise Apiwork::SerializationError, "Serialization error for #{schema_name}: #{e.message}"
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
          next unless should_include_association?(association, definition)

          serialized_attributes[association] = serialize_association(association, definition)
        end

        Transform::Case.hash(serialized_attributes, self.class.serialize_key_transform)
      end

      private

      def serialize_association(name, definition)
        associated = object.public_send(name)
        return nil if associated.nil?

        resource_class = definition.schema_class || detect_association_resource(name)
        return nil unless resource_class

        # Constantize if string
        resource_class = resource_class.constantize if resource_class.is_a?(String)

        # Build nested includes for this association
        nested_includes = build_nested_includes(name)

        if definition.collection?
          associated.map { |item| resource_class.new(item, context: context, includes: nested_includes).as_json }
        else
          resource_class.new(associated, context: context, includes: nested_includes).as_json
        end
      end

      # Smart logic: serializable: true → always include, cannot be excluded
      # serializable: false → only include if explicitly in includes parameter
      def should_include_association?(name, definition)
        # serializable: true → ALWAYS include, ignore includes parameter
        return true if definition.serializable?

        # serializable: false → only include if explicitly requested
        explicitly_included?(name)
      end

      def explicitly_included?(name)
        return false if @includes.nil?

        case @includes
        when Symbol, String
          @includes.to_sym == name
        when Array
          @includes.map(&:to_sym).include?(name)
        when Hash
          @includes.key?(name) || @includes.key?(name.to_s) || @includes.key?(name.to_sym)
        else
          false
        end
      end

      def build_nested_includes(association_name)
        return nil unless @includes.is_a?(Hash)

        # Support both string and symbol keys
        @includes[association_name] || @includes[association_name.to_s] || @includes[association_name.to_sym]
      end

      def detect_association_resource(association_name)
        # Base version: just use the schema_class if provided
        # Model version will override this with ActiveRecord reflection
        definition = self.class.association_definitions[association_name]
        return nil unless definition

        resource_class = definition.schema_class
        resource_class.is_a?(String) ? resource_class.constantize : resource_class
      end
    end
  end
end
