# frozen_string_literal: true

module Apiwork
  module Adapter
    class Features
      attr_reader :filter_types,
                  :nullable_filter_types

      def initialize(structure)
        @structure = structure
        schema_classes = structure.schema_classes
        @filter_types, @nullable_filter_types = extract_filterable_type_variants(schema_classes)
        @sortable = check_sortable(schema_classes)
        @resources = structure.has_resources?
        @index_actions = structure.has_index_actions?
      end

      def sortable?
        @sortable
      end

      def filterable?
        filter_types.any?
      end

      def resources?
        @resources
      end

      def index_actions?
        @index_actions
      end

      def options_for(option, key = nil)
        @structure.schema_classes
          .filter_map { |schema| schema.adapter_config.dig(option, key) }
          .to_set
      end

      private

      def extract_filterable_type_variants(schemas)
        filterable_attributes = schemas
          .flat_map { |schema| schema.attributes.values }
          .select(&:filterable?)

        filterable = filterable_attributes.map(&:type).to_set
        nullable = filterable_attributes.select(&:nullable?).map(&:type).to_set

        [filterable.to_a, nullable.to_a]
      end

      def check_sortable(schemas)
        schemas.any? do |schema|
          schema.attributes.values.any?(&:sortable?) ||
            schema.associations.values.any?(&:sortable?)
        end
      end
    end
  end
end
