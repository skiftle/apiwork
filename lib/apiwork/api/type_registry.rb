# frozen_string_literal: true

module Apiwork
  module API
    class TypeRegistry
      def initialize
        @store = Concurrent::Map.new
      end

      def register(
        name,
        scope: nil,
        deprecated: false,
        description: nil,
        example: nil,
        format: nil,
        schema_class: nil,
        &definition
      )
        key = scoped_name(scope, name)

        if @store.key?(key)
          merge(
            key,
            definition:,
            deprecated:,
            description:,
            example:,
            format:,
            schema_class:,
          )
        else
          @store[key] = TypeDefinition.new(
            definition:,
            deprecated:,
            description:,
            example:,
            format:,
            schema_class:,
            scope:,
            name: key,
          )
        end
      end

      def register_union(name, payload, scope: nil)
        key = scoped_name(scope, name)
        @store[key] = TypeDefinition.new(payload:, scope:, name: key)
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
        definitions(name, scope:).present?
      end

      def definitions(name, scope: nil)
        definition = scope ? @store[scoped_name(scope, name)] : nil
        definition ||= @store[name]
        definition&.all_definitions
      end

      def metadata(name)
        @store[name]
      end

      def schema_class(name, scope: nil)
        definition = scope ? @store[scoped_name(scope, name)] : nil
        definition ||= @store[name]
        definition&.schema_class
      end

      def scoped_name(scope, name)
        return name unless scope

        prefix = scope.respond_to?(:scope_prefix) ? scope.scope_prefix : nil
        return name unless prefix
        return prefix.to_sym if name.nil?
        return prefix.to_sym if name.to_s.empty?
        return name.to_sym if name.to_s == prefix

        :"#{prefix}_#{name}"
      end

      def clear!
        @store.clear
      end

      private

      def merge(
        key,
        definition:,
        deprecated:,
        description:,
        example:,
        format:,
        schema_class:
      )
        existing = @store[key]
        @store[key] = existing.merge(
          definition:,
          deprecated:,
          description:,
          example:,
          format:,
          schema_class:,
        )
      end
    end
  end
end
