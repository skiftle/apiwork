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
    end
  end
end
