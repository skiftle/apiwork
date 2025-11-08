# frozen_string_literal: true


module Apiwork
  module Contract
    module Descriptors
      # Unified registry facade for both types and enums
      # Delegates to TypeStore and EnumStore for specific operations
      class Registry
        class << self
          # ==========================================
          # Type Methods (delegate to TypeStore)
          # ==========================================

          # Register a global type (shared across all contracts)
          #
          # @param name [Symbol] Type name (e.g., :string_filter)
          # @param block [Proc] Type definition block
          def register_global(name, &block)
            TypeStore.register_global(name, &block)
          end

          # Register a local type (scoped to a contract)
          #
          # @param contract_class [Class] Contract class defining this type
          # @param name [Symbol] Short type name (e.g., :filter)
          # @param block [Proc] Type definition block
          def register_local(contract_class, name, &block)
            TypeStore.register_local(contract_class, name, &block)
          end

          # Resolve a type definition
          #
          # @param name [Symbol] Type name to resolve
          # @param contract_class [Class] Contract class for scope resolution
          # @return [Proc, nil] Type definition block or nil if not found
          def resolve(name, contract_class:)
            TypeStore.resolve(name, contract_class: contract_class)
          end

          # Check if a type is registered as global
          #
          # @param name [Symbol] Type name
          # @return [Boolean]
          def global?(name)
            TypeStore.global?(name)
          end

          # Check if a type is registered locally for a contract
          #
          # @param name [Symbol] Type name
          # @param contract_class [Class] Contract class
          # @return [Boolean]
          def local?(name, contract_class)
            TypeStore.local?(name, contract_class)
          end

          # Get qualified name for a type
          #
          # @param contract_class [Class] Contract class
          # @param name [Symbol] Short type name
          # @return [Symbol] Qualified type name
          def qualified_name(contract_class, name)
            TypeStore.qualified_name(contract_class, name)
          end

          # Get all registered global type names
          #
          # @return [Array<Symbol>] Array of global type names
          def all_global_types
            TypeStore.all_global
          end

          # Get all local types for a contract
          #
          # @param contract_class [Class] Contract class
          # @return [Hash] Hash of {short_name => metadata}
          def all_local_types(contract_class)
            TypeStore.all_local(contract_class)
          end

          # Serialize ALL types for an API's as_json output
          #
          # @param api [Apiwork::API::Base] The API instance
          # @return [Hash] { type_name => type_definition }
          def serialize_all_types_for_api(api)
            TypeStore.serialize_all_for_api(api)
          end

          # ==========================================
          # Enum Methods (delegate to EnumStore)
          # ==========================================

          # Register a global enum (shared across all contracts)
          #
          # @param name [Symbol] Enum name (e.g., :status)
          # @param values [Array] Enum values (e.g., %w[draft published])
          def register_global_enum(name, values)
            EnumStore.register_global(name, values)
          end

          # Register a local enum (scoped to a contract, action, or definition)
          #
          # @param scope [Class, Object] Scope object (Contract class or Definition instance)
          # @param name [Symbol] Short enum name (e.g., :status)
          # @param values [Array] Enum values (e.g., %w[draft published])
          def register_local_enum(scope, name, values)
            EnumStore.register_local(scope, name, values)
          end

          # Resolve an enum with lexical scoping
          #
          # @param name [Symbol] Enum name to resolve
          # @param scope [Object] Scope object (Definition, ActionDefinition, Contract class)
          # @return [Array, nil] Enum values array or nil if not found
          def resolve_enum(name, scope:)
            EnumStore.resolve(name, scope: scope)
          end

          # Check if an enum is registered as global
          #
          # @param name [Symbol] Enum name
          # @return [Boolean]
          def global_enum?(name)
            EnumStore.global?(name)
          end

          # Check if an enum is registered locally for a scope
          #
          # @param name [Symbol] Enum name
          # @param scope [Object] Scope object
          # @return [Boolean]
          def local_enum?(name, scope)
            EnumStore.local?(name, scope)
          end

          # Get qualified name for an enum
          #
          # @param scope [Object] Scope object (Contract class, Definition instance, etc.)
          # @param name [Symbol] Short enum name
          # @return [Symbol] Qualified enum name
          def qualified_enum_name(scope, name)
            EnumStore.qualified_name(scope, name)
          end

          # Serialize ALL enums for an API's as_json output
          #
          # @param api [Apiwork::API::Base] The API instance
          # @return [Hash] { enum_name => values_array }
          def serialize_all_enums_for_api(api)
            EnumStore.serialize_all_for_api(api)
          end

          # ==========================================
          # Shared Methods
          # ==========================================

          # Clear all registered types and enums (useful for testing)
          def clear!
            TypeStore.clear!
            EnumStore.clear!
          end

          # Get all registered types and enums as hash (for debugging)
          #
          # @return [Hash] { global_types: [...], global_enums: [...], ... }
          def all_for_json
            {
              global_types: TypeStore.all_global,
              global_enums: EnumStore.all_global
            }
          end
        end
      end
    end
  end
end
