# frozen_string_literal: true

module Apiwork
  module API
    class TypeRegistry
      def initialize
        @store = Concurrent::Map.new
      end

      def register(
        name,
        kind:,
        scope: nil,
        deprecated: false,
        description: nil,
        discriminator: nil,
        example: nil,
        format: nil,
        schema_class: nil,
        &block
      )
        key = scoped_name(scope, name)

        if @store.key?(key)
          validate_kind_consistency!(key, kind)
          merge(key, block:, deprecated:, description:, example:, format:)
        else
          @store[key] = TypeDefinition.new(
            key,
            block:,
            deprecated:,
            description:,
            discriminator:,
            example:,
            format:,
            kind:,
            schema_class:,
            scope:,
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
        definition = scope ? @store[scoped_name(scope, name)] : nil
        definition || @store[name]
      end

      def schema_class(name, scope: nil)
        find(name, scope:)&.schema_class
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

      def validate_kind_consistency!(key, new_kind)
        existing = @store[key]
        return if existing.kind == new_kind

        raise ConfigurationError,
              "Cannot redefine :#{key} as #{new_kind}, already defined as #{existing.kind}"
      end

      def merge(key, block:, deprecated:, description:, example:, format:)
        existing = @store[key]
        @store[key] = existing.merge(
          block:,
          deprecated:,
          description:,
          example:,
          format:,
        )
      end
    end
  end
end
