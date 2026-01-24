# frozen_string_literal: true

module Apiwork
  module API
    class SchemaRegistry
      def initialize
        @store = Set.new
        @roles = Hash.new { |hash, key| hash[key] = Set.new }
      end

      def register(schema_class)
        @store.add(schema_class)
      end

      def mark(schema_class, role)
        @roles[schema_class].add(role)
      end

      def nested_writable?(schema_class)
        @roles[schema_class].include?(:nested_writable)
      end

      def each(&block)
        @store.each(&block)
      end

      def include?(schema_class)
        @store.include?(schema_class)
      end

      def clear!
        @store.clear
        @roles.clear
      end
    end
  end
end
