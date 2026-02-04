# frozen_string_literal: true

module Apiwork
  module API
    class EnumRegistry
      def initialize
        @store = Concurrent::Map.new
      end

      def register(
        name,
        values = nil,
        scope: nil,
        deprecated: false,
        description: nil,
        example: nil
      )
        key = scoped_name(scope, name)

        if @store.key?(key)
          merge(
            key,
            deprecated:,
            description:,
            example:,
            values:,
          )
        else
          @store[key] = EnumDefinition.new(
            key,
            deprecated:,
            description:,
            example:,
            scope:,
            values:,
          )
        end
      end

      def [](name)
        @store[name]
      end

      def key?(name)
        @store.key?(name)
      end

      def each_pair(&block)
        @store.each_pair(&block)
      end

      def exists?(name, scope: nil)
        find(name, scope:).present?
      end

      def find(name, scope: nil)
        (scope ? @store[scoped_name(scope, name)] : nil) || @store[name]
      end

      def values(name, scope: nil)
        find(name, scope:)&.values
      end

      def scoped_name(scope, name)
        return name unless scope

        prefix = scope.respond_to?(:scope_prefix) ? scope.scope_prefix : nil
        return name unless prefix
        return prefix.to_sym if name.nil?
        return prefix.to_sym if name.to_s.empty?
        return name.to_sym if name.to_s == prefix

        [prefix, name].join('_').to_sym
      end

      def clear!
        @store.clear
      end

      private

      def merge(
        key,
        deprecated:,
        description:,
        example:,
        values:
      )
        @store[key] = @store[key].merge(
          deprecated:,
          description:,
          example:,
          values:,
        )
      end
    end
  end
end
