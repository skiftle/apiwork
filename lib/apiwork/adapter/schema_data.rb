# frozen_string_literal: true

module Apiwork
  module Adapter
    class SchemaData
      attr_reader :filterable_types,
                  :nullable_filterable_types

      def initialize(schemas)
        @filterable_types, @nullable_filterable_types = extract_filterable_type_variants(schemas)
        @sortable = check_sortable(schemas)
      end

      def sortable?
        @sortable
      end

      private

      def extract_filterable_type_variants(schemas)
        filterable = Set.new
        nullable = Set.new

        schemas.each do |schema|
          schema.attribute_definitions.each_value do |attribute_definition|
            next unless attribute_definition.filterable?

            type = attribute_definition.type
            filterable.add(type)
            nullable.add(type) if attribute_definition.nullable?
          end
        end

        [filterable.to_a, nullable.to_a]
      end

      def check_sortable(schemas)
        schemas.any? do |schema|
          schema.attribute_definitions.values.any?(&:sortable?) ||
            schema.association_definitions.values.any?(&:sortable?)
        end
      end
    end
  end
end
