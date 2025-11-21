# frozen_string_literal: true

module Apiwork
  module Schema
    module Serialization
      extend ActiveSupport::Concern

      class_methods do
        def serialize(object_or_collection, context: {}, includes: nil)
          if object_or_collection.respond_to?(:each)
            object_or_collection.map { |obj| serialize_single(obj, context: context, includes: includes) }
          else
            serialize_single(object_or_collection, context: context, includes: includes)
          end
        rescue StandardError => e
          schema_name = respond_to?(:name) ? name : 'Schema'
          raise Apiwork::SchemaError, "Serialization error for #{schema_name}: #{e.message}"
        end

        def serialize_single(obj, context: {}, includes: nil)
          if respond_to?(:sti_base?) && sti_base?
            variant_schema = resolve_sti_variant_for_object(obj)
            return variant_schema.new(obj, context: context, includes: includes).as_json if variant_schema
          end

          new(obj, context: context, includes: includes).as_json
        end

        def resolve_sti_variant_for_object(obj)
          discriminator_column = self.discriminator_column
          sti_type = obj.public_send(discriminator_column)

          variant = variants.find { |_tag, data| data[:sti_type] == sti_type }
          return nil unless variant

          variant.last[:schema]
        end
      end

      def as_json
        serialized_attributes = {}

        add_discriminator_field(serialized_attributes) if self.class.respond_to?(:sti_variant?) && self.class.sti_variant?

        self.class.attribute_definitions.each do |attribute, definition|
          value = respond_to?(attribute) ? public_send(attribute) : object.public_send(attribute)
          value = definition.serialize(value)
          serialized_attributes[attribute] = value
        end

        self.class.association_definitions.each do |association, definition|
          next unless should_include_association?(association, definition)

          serialized_attributes[association] = serialize_association(association, definition)
        end

        transform_keys(serialized_attributes)
      end

      private

      def add_discriminator_field(serialized_attributes)
        parent_schema = self.class.superclass
        return unless parent_schema.respond_to?(:discriminator_name)

        discriminator_name = parent_schema.discriminator_name
        variant_tag = self.class.variant_tag

        serialized_attributes[discriminator_name] = variant_tag.to_s
      end

      def transform_keys(hash)
        case self.class.output_key_format
        when :camel
          hash.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
        when :underscore
          hash.deep_transform_keys { |key| key.to_s.underscore.to_sym }
        else
          hash
        end
      end

      def serialize_association(name, definition)
        associated = object.public_send(name)
        return nil if associated.nil?

        resource_class = definition.schema_class || detect_association_resource(name)
        return nil unless resource_class

        resource_class = resource_class.constantize if resource_class.is_a?(String)

        nested_includes = build_nested_includes(name)

        if definition.collection?
          associated.map { |item| serialize_sti_aware(item, resource_class, nested_includes) }
        else
          serialize_sti_aware(associated, resource_class, nested_includes)
        end
      end

      def serialize_sti_aware(item, resource_class, nested_includes)
        if resource_class.respond_to?(:sti_base?) && resource_class.sti_base?
          variant_schema = resolve_sti_variant_schema(item, resource_class)
          return variant_schema.new(item, context: context, includes: nested_includes).as_json if variant_schema
        end

        resource_class.new(item, context: context, includes: nested_includes).as_json
      end

      def resolve_sti_variant_schema(item, base_schema)
        discriminator_column = base_schema.discriminator_column
        sti_type = item.public_send(discriminator_column)

        variant = base_schema.variants.find { |_tag, data| data[:sti_type] == sti_type }
        return nil unless variant

        variant.last[:schema]
      end

      def should_include_association?(name, definition)
        return true if definition.always_included?

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
          name_sym = name.to_sym
          @includes.key?(name_sym) || @includes.key?(name_sym.to_s)
        else
          false
        end
      end

      def build_nested_includes(association_name)
        return nil unless @includes.is_a?(Hash)

        @includes[association_name] || @includes[association_name.to_s] || @includes[association_name.to_sym]
      end
    end
  end
end
