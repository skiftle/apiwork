# frozen_string_literal: true

module Apiwork
  module Schema
    # @api private
    module Serialization
      extend ActiveSupport::Concern

      class_methods do
        def serialize(object_or_collection, context: {}, include: nil)
          if object_or_collection.respond_to?(:each)
            object_or_collection.map { |obj| serialize_single(obj, context: context, include: include) }
          else
            serialize_single(object_or_collection, context: context, include: include)
          end
        rescue StandardError => e
          schema_name = respond_to?(:name) ? name : 'Schema'
          raise Apiwork::SchemaError, "Serialization error for #{schema_name}: #{e.message}"
        end

        def serialize_single(obj, context: {}, include: nil)
          if respond_to?(:sti_base?) && sti_base?
            variant_schema = resolve_sti_variant(obj)
            return variant_schema.new(obj, context: context, include: include).as_json if variant_schema
          end

          new(obj, context: context, include: include).as_json
        end

        def resolve_sti_variant(obj)
          sti_type = obj.public_send(discriminator_column)
          variant = variants.find { |_tag, data| data[:sti_type] == sti_type }
          variant&.last&.[](:schema)
        end
      end

      def as_json
        serialized_attributes = {}

        add_discriminator_field(serialized_attributes) if self.class.respond_to?(:sti_variant?) && self.class.sti_variant?

        self.class.attribute_definitions.each do |attribute, definition|
          value = respond_to?(attribute) ? public_send(attribute) : object.public_send(attribute)
          value = definition.encode(value)
          serialized_attributes[attribute] = value
        end

        self.class.association_definitions.each do |association, definition|
          next unless should_include_association?(association, definition)

          serialized_attributes[association] = serialize_association(association, definition)
        end

        serialized_attributes
      end

      private

      def add_discriminator_field(serialized_attributes)
        parent_schema = self.class.superclass
        return unless parent_schema.respond_to?(:discriminator_name)

        discriminator_name = parent_schema.discriminator_name
        variant_tag = self.class.variant_tag

        serialized_attributes[discriminator_name] = variant_tag.to_s
      end

      def serialize_association(name, definition)
        associated = object.public_send(name)
        return nil if associated.nil?

        resource_class = definition.schema_class || resolve_association_schema(name)
        return nil unless resource_class

        resource_class = resource_class.constantize if resource_class.is_a?(String)

        nested_includes = @include[name] || @include[name.to_s] || @include[name.to_sym] if @include.is_a?(Hash)

        if definition.collection?
          associated.map { |item| serialize_sti_aware(item, resource_class, nested_includes) }
        else
          serialize_sti_aware(associated, resource_class, nested_includes)
        end
      end

      def resolve_association_schema(association_name)
        return nil unless self.class.respond_to?(:model_class)
        return nil unless self.class.model_class

        reflection = object.class.reflect_on_association(association_name)
        return nil unless reflection
        return nil if reflection.polymorphic?

        namespace = self.class.name.deconstantize
        "#{namespace}::#{reflection.klass.name}Schema".safe_constantize
      end

      def serialize_sti_aware(item, resource_class, nested_includes)
        if resource_class.respond_to?(:sti_base?) && resource_class.sti_base?
          variant_schema = resource_class.resolve_sti_variant(item)
          return variant_schema.new(item, context: context, include: nested_includes).as_json if variant_schema
        end

        resource_class.new(item, context: context, include: nested_includes).as_json
      end

      def should_include_association?(name, definition)
        return true if definition.always_included?

        explicitly_included?(name)
      end

      def explicitly_included?(name)
        return false if @include.nil?

        case @include
        when Symbol, String
          @include.to_sym == name
        when Array
          include_symbols.include?(name)
        when Hash
          name = name.to_sym
          @include.key?(name) || @include.key?(name.to_s)
        else
          false
        end
      end

      def include_symbols
        @include_symbols ||= @include.map(&:to_sym)
      end
    end
  end
end
