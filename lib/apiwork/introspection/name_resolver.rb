# frozen_string_literal: true

module Apiwork
  module Introspection
    class NameResolver
      def initialize
        @import_prefix_cache = {}
      end

      def scope_for_type(definition)
        definition.contract_class
      end

      def scope_for_enum(definition, enum_name)
        definition.contract_class
      end

      def global_type?(type_name, definition)
        return false unless definition.contract_class.respond_to?(:api_class)

        api_class = definition.contract_class.api_class
        return false unless api_class

        type_global_for_api?(type_name, api_class: api_class)
      end

      def type_global_for_api?(type_name, api_class:)
        metadata = api_class.type_system.type_metadata(type_name)
        return false unless metadata

        metadata[:scope].nil?
      end

      def enum_global_for_api?(enum_name, api_class:)
        metadata = api_class.type_system.enum_metadata(enum_name)
        return false unless metadata

        metadata[:scope].nil?
      end

      def imported_type?(type_name, definition)
        return false unless definition.contract_class.respond_to?(:imports)

        import_prefixes = import_prefix_cache(definition.contract_class)

        return true if import_prefixes[:direct].include?(type_name)

        type_name = type_name.to_s
        import_prefixes[:prefixes].any? { |prefix| type_name.start_with?(prefix) }
      end

      def qualified_name(type_name, definition)
        return type_name if global_type?(type_name, definition)
        return type_name if global_enum?(type_name, definition)
        return type_name if imported_type?(type_name, definition)

        scope = scope_for_type(definition)
        api_class = definition.contract_class.api_class
        api_class&.scoped_name(scope, type_name) || type_name
      end

      def global_enum?(enum_name, definition)
        return false unless definition.contract_class.respond_to?(:api_class)

        api_class = definition.contract_class.api_class
        return false unless api_class

        enum_global_for_api?(enum_name, api_class: api_class)
      end

      private

      def import_prefix_cache(contract_class)
        @import_prefix_cache[contract_class] ||= begin
          direct = Set.new(contract_class.imports.keys)
          { direct: direct, prefixes: contract_class.imports.keys.map { |alias_name| "#{alias_name}_" } }
        end
      end
    end
  end
end
