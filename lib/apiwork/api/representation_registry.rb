# frozen_string_literal: true

module Apiwork
  module API
    class RepresentationRegistry
      def initialize
        @store = Set.new
        @roles = Hash.new { |hash, key| hash[key] = Set.new }
      end

      def register(representation_class)
        @store.add(representation_class)
      end

      def mark(representation_class, role)
        @roles[representation_class].add(role)
      end

      def nested_writable?(representation_class)
        @roles[representation_class].include?(:nested_writable)
      end

      def each(&block)
        @store.each(&block)
      end

      def include?(representation_class)
        @store.include?(representation_class)
      end

      def clear!
        @store.clear
        @roles.clear
      end

      def filter_types
        @filter_types ||= extract_filter_types(nullable: false)
      end

      def nullable_filter_types
        @nullable_filter_types ||= extract_filter_types(nullable: true)
      end

      def sortable?
        return @sortable if defined?(@sortable)

        @sortable = @store.any? do |representation|
          representation.attributes.values.any?(&:sortable?) ||
            representation.associations.values.any?(&:sortable?)
        end
      end

      def filterable?
        filter_types.any?
      end

      def options_for(option, key = nil)
        @store.filter_map { |representation| representation.adapter_config.dig(option, key) }.to_set
      end

      private

      def extract_filter_types(nullable:)
        filterable_attributes = @store
          .flat_map { |representation| representation.attributes.values }
          .select(&:filterable?)

        if nullable
          filterable_attributes.select(&:nullable?).map(&:type).to_set.to_a
        else
          filterable_attributes.map(&:type).to_set.to_a
        end
      end
    end
  end
end
