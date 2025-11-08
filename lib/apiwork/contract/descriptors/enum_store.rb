# frozen_string_literal: true


module Apiwork
  module Contract
    module Descriptors
      # EnumStore handles enum registration and resolution
      # Enums are stored as Arrays of allowed values with complex lexical scoping
      class EnumStore < Base
        class << self
          # Register a global enum (shared across all contracts)
          #
          # @param name [Symbol] Enum name (e.g., :status)
          # @param values [Array] Enum values (e.g., %w[draft published])
          # @raise [ArgumentError] if enum already registered
          def register_global(name, values)
            super(name, values)
          end

          # Register a local enum (scoped to a contract, action, or definition)
          #
          # @param scope [Class, Object] Scope object (Contract class or Definition instance)
          # @param name [Symbol] Short enum name (e.g., :status)
          # @param values [Array] Enum values (e.g., %w[draft published])
          def register_local(scope, name, values)
            super(scope, name, values, { values: values })
          end

          # Resolve an enum with lexical scoping
          #
          # Resolution order (lexical scoping):
          # 1. Local enums in the given scope (most specific - Definition instance)
          # 2. Parent scopes (Definition → ActionDefinition → Contract)
          # 3. Global enums
          #
          # @param name [Symbol] Enum name to resolve
          # @param scope [Object] Scope object (Definition, ActionDefinition, Contract class)
          # @return [Array, nil] Enum values array or nil if not found
          def resolve(name, scope:)
            # First check if this exact scope has the enum
            if local_storage[scope]&.key?(name)
              return local_storage[scope][name][:values]
            end

            # If scope is a Definition, walk up the scope chain
            if scope.respond_to?(:parent_scope) && scope.parent_scope
              result = resolve(name, scope: scope.parent_scope)
              return result if result
            end

            # If scope is a Definition with an action_name, check the ActionDefinition
            # This is needed because Definitions created inside action blocks don't have parent_scope set
            # but should still be able to resolve action-level enums
            if scope.class.name == 'Apiwork::Contract::Definition' && scope.respond_to?(:action_name) && scope.action_name
              # Try to find the ActionDefinition for this action
              contract_class = scope.contract_class
              action_def = contract_class.action_definition(scope.action_name) if contract_class.respond_to?(:action_definition)
              if action_def && local_storage[action_def]&.key?(name)
                return local_storage[action_def][name][:values]
              end
            end

            # If scope is a Definition or ActionDefinition, also check its contract class
            if scope.respond_to?(:contract_class)
              contract_class = scope.contract_class
              if local_storage[contract_class]&.key?(name)
                return local_storage[contract_class][name][:values]
              end
            end

            # Fall back to global enums
            global_storage[name]
          end

          # Get qualified name for an enum (used in as_json output)
          #
          # Global enums keep their name
          # Local enums get prefixed based on their scope
          #
          # @param scope [Object] Scope object (Contract class, Definition instance, etc.)
          # @param name [Symbol] Short enum name
          # @return [Symbol] Qualified enum name
          #
          # @example
          #   # Contract-level enum
          #   qualified_name(PostContract, :status)
          #   # => :post_status
          #
          #   # Action-level enum (Definition with action_name)
          #   qualified_name(definition_instance, :priority)
          #   # => :post_create_priority
          #
          #   # Global enum
          #   qualified_name(anything, :global_status)
          #   # => :global_status
          def qualified_name(scope, name)
            # Global enums keep their name
            return name if global?(name)

            # Extract prefix based on scope type
            if scope.is_a?(Class)
              # Contract-level enum
              contract_prefix = extract_contract_prefix(scope)
              return :"#{contract_prefix}_#{name}"
            elsif scope.respond_to?(:contract_class) && scope.respond_to?(:action_name)
              # Action/Definition-level enum
              contract_prefix = extract_contract_prefix(scope.contract_class)
              action_name = scope.action_name

              # Check if this is an input/output definition (has direction)
              if scope.respond_to?(:direction)
                direction = scope.direction
                return :"#{contract_prefix}_#{action_name}_#{direction}_#{name}"
              else
                # Action-level (no direction)
                return :"#{contract_prefix}_#{action_name}_#{name}"
              end
            else
              # Fallback: just use the name
              name
            end
          end

          # Serialize ALL enums for an API's as_json output
          # Returns a single hash with all global enums + all local enums from all scopes
          #
          # @param api [Apiwork::API::Base] The API instance
          # @return [Hash] { enum_name => values_array }
          def serialize_all_for_api(api)
            result = {}

            # Add all global enums (no prefix)
            global_storage.each do |enum_name, values|
              result[enum_name] = values
            end

            # Add all local enums from all scopes (prefixed)
            # Convert to array to prevent iteration issues
            local_storage.to_a.each do |scope, enums|
              enums.to_a.each do |_enum_name, metadata|
                qualified_enum_name = metadata[:qualified_name]
                values = metadata[:values]

                result[qualified_enum_name] = values
              end
            end

            result
          end

          protected

          def storage_name
            :enums
          end
        end
      end
    end
  end
end
