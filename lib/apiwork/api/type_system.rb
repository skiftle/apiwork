# frozen_string_literal: true

module Apiwork
  module API
    class TypeSystem
      attr_reader :enums,
                  :types

      def initialize
        @types = Apiwork::Store.new
        @enums = Apiwork::Store.new
      end

      def register_type(name, scope: nil, description: nil, example: nil, format: nil, deprecated: false,
                        schema_class: nil, &block)
        key = scoped_name(scope, name)

        if @types.key?(key)
          merge_type(key, description:, example:, format:, deprecated:, schema_class:, block:)
        else
          @types[key] = { scope:, definition: block, definitions: nil, description:, example:, format:,
                          deprecated:, schema_class: }
        end
      end

      def register_union(name, payload, scope: nil)
        key = scoped_name(scope, name)
        @types[key] = { scope:, payload: }
      end

      def resolve_type(name, scope: nil)
        metadata = if scope
                     scoped_name_value = scoped_name(scope, name)
                     @types[scoped_name_value] if @types.key?(scoped_name_value)
                   end
        metadata ||= @types[name]

        return nil unless metadata

        (metadata[:definitions] || [metadata[:definition]].compact).presence
      end

      def type_metadata(name)
        @types[name]
      end

      def scoped_name(scope, name)
        return name unless scope

        prefix = scope.respond_to?(:scope_prefix) ? scope.scope_prefix : nil
        return name unless prefix
        return prefix.to_sym if name.nil? || name.to_s.empty?
        return name.to_sym if name.to_s == prefix

        :"#{prefix}_#{name}"
      end

      def register_enum(name, values = nil, scope: nil, description: nil, example: nil, deprecated: false)
        key = scoped_name(scope, name)

        if @enums.key?(key)
          merge_enum(key, values:, description:, example:, deprecated:)
        else
          @enums[key] = { scope:, values:, description:, example:, deprecated: }
        end
      end

      def resolve_enum(name, scope: nil)
        if scope
          scoped_name_value = scoped_name(scope, name)
          return @enums[scoped_name_value]&.dig(:values) if @enums.key?(scoped_name_value)
        end
        @enums[name]&.dig(:values)
      end

      def clear!
        @types.clear!
        @enums.clear!
      end

      private

      def merge_type(key, description:, example:, format:, deprecated:, schema_class:, block:)
        existing = @types[key]

        merged_definitions = existing[:definitions]&.dup || []
        merged_definitions << existing[:definition] if existing[:definition] && existing[:definitions].nil?
        merged_definitions << block if block

        @types[key] = existing.merge(
          description: description || existing[:description],
          example: example || existing[:example],
          format: format || existing[:format],
          deprecated: deprecated || existing[:deprecated],
          schema_class: schema_class || existing[:schema_class],
          definition: nil,
          definitions: merged_definitions.compact.presence
        )
      end

      def merge_enum(key, values:, description:, example:, deprecated:)
        existing = @enums[key]
        @enums[key] = existing.merge(
          description: description || existing[:description],
          example: example || existing[:example],
          deprecated: deprecated || existing[:deprecated],
          values: values || existing[:values]
        )
      end
    end
  end
end
