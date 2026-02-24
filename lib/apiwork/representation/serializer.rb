# frozen_string_literal: true

module Apiwork
  module Representation
    class Serializer
      class << self
        def serialize(representation, includes)
          new(representation, includes).serialize
        end
      end

      def initialize(representation, includes)
        @representation = representation
        @representation_class = representation.class
        @includes = includes
      end

      def serialize
        fields = {}

        add_discriminator_field(fields) if @representation_class.subclass?

        @representation_class.attributes.each do |name, attribute|
          value = @representation.respond_to?(name) ? @representation.public_send(name) : @representation.record.public_send(name)
          value = map_type_column_output(name, value)
          value = attribute.encode(value)
          fields[name] = value
        end

        @representation_class.associations.each do |name, association|
          next unless include_association?(name, association)

          fields[name] = serialize_association(name, association)
        end

        fields
      end

      private

      def add_discriminator_field(fields)
        parent_representation = @representation_class.superclass
        return unless parent_representation.inheritance

        fields[parent_representation.inheritance.column] = @representation_class.sti_name
      end

      def map_type_column_output(attribute_name, value)
        return value if value.nil?

        association = @representation_class.polymorphic_association_for_type_column(attribute_name)
        if association
          found_class = association.find_representation_for_type(value)
          return found_class.polymorphic_name if found_class
        end

        inheritance = @representation_class.inheritance_for_column(attribute_name)
        if inheritance
          klass = inheritance.subclasses.find { |subclass| subclass.model_class.sti_name == value }
          return klass.sti_name if klass
        end

        value
      end

      def serialize_association(name, association)
        target = @representation.respond_to?(name) ? @representation.public_send(name) : @representation.record.public_send(name)
        return nil if target.nil?

        target_representation_class = association.representation_class
        return nil unless target_representation_class

        nested_includes = @includes[name] || @includes[name.to_s] || @includes[name.to_sym] if @includes.is_a?(Hash)

        if association.collection?
          target.map { |record| serialize_variant_aware(record, target_representation_class, nested_includes) }
        else
          serialize_variant_aware(target, target_representation_class, nested_includes)
        end
      end

      def serialize_variant_aware(record, target_representation_class, nested_includes)
        if target_representation_class.inheritance&.subclasses&.any?
          subclass_representation_class = target_representation_class.inheritance.resolve(record)
        end
        representation_class = subclass_representation_class || target_representation_class

        representation_class.new(record, context: @representation.context, include: nested_includes).as_json
      end

      def include_association?(name, association)
        return explicitly_included?(name) unless association.include == :always
        return true unless circular_reference?(association)

        false
      end

      def circular_reference?(association)
        return false unless association.representation_class

        association.representation_class.associations.values.any? do |nested_association|
          nested_association.include == :always && nested_association.representation_class == @representation_class
        end
      end

      def explicitly_included?(name)
        return false if @includes.nil?

        case @includes
        when Symbol, String
          @includes.to_sym == name
        when Array
          include_symbols.include?(name)
        when Hash
          name = name.to_sym
          @includes.key?(name) || @includes.key?(name.to_s)
        else
          false
        end
      end

      def include_symbols
        @include_symbols ||= @includes.map(&:to_sym)
      end
    end
  end
end
