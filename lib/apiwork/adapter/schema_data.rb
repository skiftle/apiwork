# frozen_string_literal: true

module Apiwork
  module Adapter
    class SchemaData
      attr_reader :schema_class

      def initialize(schema_class)
        @schema_class = schema_class
      end

      def model_class
        schema_class.model_class
      end

      def root_key
        schema_class.root_key
      end

      def attribute_definitions
        schema_class.attribute_definitions
      end

      def association_definitions
        schema_class.association_definitions
      end

      def filterable_fields
        @filterable_fields ||= build_filterable_fields
      end

      def sortable_fields
        @sortable_fields ||= build_sortable_fields
      end

      def writable_attributes(context)
        attribute_definitions.select { |_name, defn| defn.writable?(context) }
      end

      def writable_associations(context)
        association_definitions.select { |_name, defn| defn.writable?(context) }
      end

      def filterable?
        filterable_fields.any?
      end

      def sortable?
        sortable_fields.any?
      end

      private

      def build_filterable_fields
        fields = {}

        attribute_definitions.each do |name, definition|
          next unless definition.filterable?

          fields[name] = {
            type: definition.type,
            operators: definition.filter_operators
          }
        end

        association_definitions.each do |name, definition|
          next unless definition.filterable?

          fields[name] = {
            type: :association,
            nested: true
          }
        end

        fields
      end

      def build_sortable_fields
        fields = {}

        attribute_definitions.each do |name, definition|
          next unless definition.sortable?

          fields[name] = { type: definition.type }
        end

        association_definitions.each do |name, definition|
          next unless definition.sortable?

          fields[name] = {
            type: :association,
            nested: true
          }
        end

        fields
      end
    end
  end
end
