# frozen_string_literal: true

module Apiwork
  module Adapter
    class Features
      attr_reader :filter_types,
                  :nullable_filter_types

      def initialize(root_resource)
        @root_resource = root_resource
        representation_classes = root_resource.representation_classes
        @filter_types, @nullable_filter_types = extract_filterable_type_variants(representation_classes)
        @sortable = check_sortable(representation_classes)
        @resources = root_resource.has_resources?
        @index_actions = root_resource.has_index_actions?
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
        @root_resource.representation_classes
          .filter_map { |representation| representation.adapter_config.dig(option, key) }
          .to_set
      end

      private

      def extract_filterable_type_variants(representations)
        filterable_attributes = representations
          .flat_map { |representation| representation.attributes.values }
          .select(&:filterable?)

        filterable = filterable_attributes.map(&:type).to_set
        nullable = filterable_attributes.select(&:nullable?).map(&:type).to_set

        [filterable.to_a, nullable.to_a]
      end

      def check_sortable(representations)
        representations.any? do |representation|
          representation.attributes.values.any?(&:sortable?) ||
            representation.associations.values.any?(&:sortable?)
        end
      end
    end
  end
end
