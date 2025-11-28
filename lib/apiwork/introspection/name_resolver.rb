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
        store = API::Descriptor::TypeStore.send(:storage, api_class)
        metadata = store[type_name]
        return false unless metadata

        metadata[:scope].nil?
      end

      def imported_type?(type_name, definition)
        return false unless definition.contract_class.respond_to?(:imports)

        import_prefixes = import_prefix_cache(definition.contract_class)

        return true if import_prefixes[:direct].include?(type_name)

        type_name_str = type_name.to_s
        import_prefixes[:prefixes].any? { |prefix| type_name_str.start_with?(prefix) }
      end

      def qualified_name(type_name, definition)
        return type_name if global_type?(type_name, definition)
        return type_name if imported_type?(type_name, definition)
        return type_name unless definition.contract_class.respond_to?(:schema_class)
        return type_name unless definition.contract_class.schema_class

        scope = scope_for_type(definition)
        api_class = definition.contract_class.api_class
        api_class&.scoped_type_name(scope, type_name) || type_name
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
