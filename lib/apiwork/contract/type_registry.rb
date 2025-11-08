# frozen_string_literal: true

module Apiwork
  module Contract
    # TypeRegistry: Centralized storage for all custom types and enums
    #
    # Manages two categories of types and enums:
    # 1. Global - Shared across all contracts (e.g., string_filter, common enums)
    # 2. Local - Scoped to specific contracts/actions/definitions
    #
    # Both types and enums support lexical scoping:
    # - Global scope (available everywhere)
    # - Contract scope (available in contract and its actions)
    # - Action scope (available in action's input/output)
    # - Definition scope (available in specific input/output block)
    #
    # Global types/enums are registered via Apiwork.register_global_types
    # Local types/enums are registered when Contract classes or Definitions define them
    #
    # Example:
    #   # Global type (available everywhere)
    #   Apiwork.register_global_types do
    #     type :string_filter do
    #       param :eq, type: :string
    #     end
    #   end
    #
    #   # Local type (scoped to InvoiceContract)
    #   class InvoiceContract < Apiwork::Contract::Base
    #     type :filter do  # Short name internally
    #       param :id, type: :integer_filter
    #     end
    #   end
    #
    #   # Resolution
    #   TypeRegistry.resolve(:string_filter, contract_class: InvoiceContract)
    #   # => Returns global string_filter definition
    #
    #   TypeRegistry.resolve(:filter, contract_class: InvoiceContract)
    #   # => Returns InvoiceContract's filter definition
    #
    #   # Qualified name for as_json output
    #   TypeRegistry.qualified_name(:filter, InvoiceContract)
    #   # => :invoice_filter
    #
    class TypeRegistry
      class << self
        # Register a global type (shared across all contracts)
        #
        # @param name [Symbol] Type name (e.g., :string_filter)
        # @param block [Proc] Type definition block
        # @raise [ArgumentError] if type already registered
        def register_global(name, &block)
          if global_types.key?(name)
            raise ArgumentError, "Global type :#{name} already registered"
          end

          global_types[name] = block
        end

        # Register a local type (scoped to a contract)
        #
        # @param contract_class [Class] Contract class defining this type
        # @param name [Symbol] Short type name (e.g., :filter)
        # @param block [Proc] Type definition block
        def register_local(contract_class, name, &block)
          local_types[contract_class] ||= {}
          local_types[contract_class][name] = {
            short_name: name,
            qualified_name: qualified_name(contract_class, name),
            definition: block
          }
        end

        # Register a global enum (shared across all contracts)
        #
        # @param name [Symbol] Enum name (e.g., :status)
        # @param values [Array] Enum values (e.g., %w[draft published])
        # @raise [ArgumentError] if enum already registered
        def register_global_enum(name, values)
          if global_enums.key?(name)
            raise ArgumentError, "Global enum :#{name} already registered"
          end

          global_enums[name] = values
        end

        # Register a local enum (scoped to a contract, action, or definition)
        #
        # @param scope [Class, Object] Scope object (Contract class or Definition instance)
        # @param name [Symbol] Short enum name (e.g., :status)
        # @param values [Array] Enum values (e.g., %w[draft published])
        def register_local_enum(scope, name, values)
          local_enums[scope] ||= {}
          local_enums[scope][name] = {
            short_name: name,
            qualified_name: qualified_enum_name(scope, name),
            values: values
          }
        end

        # Resolve a type definition
        #
        # Resolution order:
        # 1. Local types in the given contract
        # 2. Global types
        #
        # @param name [Symbol] Type name to resolve
        # @param contract_class [Class] Contract class for scope resolution
        # @return [Proc, nil] Type definition block or nil if not found
        def resolve(name, contract_class:)
          # Check local types first (more specific)
          if local_types[contract_class]&.key?(name)
            return local_types[contract_class][name][:definition]
          end

          # Fall back to global types
          global_types[name]
        end

        # Check if a type is registered as global
        #
        # @param name [Symbol] Type name
        # @return [Boolean]
        def global?(name)
          global_types.key?(name)
        end

        # Check if a type is registered locally for a contract
        #
        # @param name [Symbol] Type name
        # @param contract_class [Class] Contract class
        # @return [Boolean]
        def local?(name, contract_class)
          local_types[contract_class]&.key?(name) || false
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
        def resolve_enum(name, scope:)
          # First check if this exact scope has the enum
          if local_enums[scope]&.key?(name)
            return local_enums[scope][name][:values]
          end

          # If scope is a Definition, walk up the scope chain
          if scope.respond_to?(:parent_scope) && scope.parent_scope
            result = resolve_enum(name, scope: scope.parent_scope)
            return result if result
          end

          # If scope is a Definition with an action_name, check the ActionDefinition
          # This is needed because Definitions created inside action blocks don't have parent_scope set
          # but should still be able to resolve action-level enums
          if scope.class.name == 'Apiwork::Contract::Definition' && scope.respond_to?(:action_name) && scope.action_name
            # Try to find the ActionDefinition for this action
            contract_class = scope.contract_class
            action_def = contract_class.action_definition(scope.action_name) if contract_class.respond_to?(:action_definition)
            if action_def && local_enums[action_def]&.key?(name)
              return local_enums[action_def][name][:values]
            end
          end

          # If scope is a Definition or ActionDefinition, also check its contract class
          if scope.respond_to?(:contract_class)
            contract_class = scope.contract_class
            if local_enums[contract_class]&.key?(name)
              return local_enums[contract_class][name][:values]
            end
          end

          # Fall back to global enums
          global_enums[name]
        end

        # Check if an enum is registered as global
        #
        # @param name [Symbol] Enum name
        # @return [Boolean]
        def global_enum?(name)
          global_enums.key?(name)
        end

        # Check if an enum is registered locally for a scope
        #
        # @param name [Symbol] Enum name
        # @param scope [Object] Scope object
        # @return [Boolean]
        def local_enum?(name, scope)
          local_enums[scope]&.key?(name) || false
        end

        # Get qualified name for a type (used in as_json output)
        #
        # Global types keep their name
        # Local types get prefixed with contract name
        #
        # @param contract_class [Class] Contract class
        # @param name [Symbol] Short type name
        # @return [Symbol] Qualified type name
        #
        # @example
        #   qualified_name(InvoiceContract, :filter)
        #   # => :invoice_filter
        #
        #   qualified_name(InvoiceContract, :string_filter)  # global type
        #   # => :string_filter
        def qualified_name(contract_class, name)
          # Global types keep their name
          return name if global?(name)

          # Local types get contract prefix
          contract_prefix = extract_contract_prefix(contract_class)

          # Special case: nil name means just use the prefix (for resource types)
          return contract_prefix.to_sym if name.nil? || name.to_s.empty?

          :"#{contract_prefix}_#{name}"
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
        #   qualified_enum_name(PostContract, :status)
        #   # => :post_status
        #
        #   # Action-level enum (Definition with action_name)
        #   qualified_enum_name(definition_instance, :priority)
        #   # => :post_create_priority
        #
        #   # Global enum
        #   qualified_enum_name(anything, :global_status)
        #   # => :global_status
        def qualified_enum_name(scope, name)
          # Global enums keep their name
          return name if global_enum?(name)

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

        # Get all registered global type names
        #
        # @return [Array<Symbol>] Array of global type names
        def all_global_types
          global_types.keys
        end

        # Get all local types for a contract
        #
        # @param contract_class [Class] Contract class
        # @return [Hash] Hash of {short_name => metadata}
        def all_local_types(contract_class)
          local_types[contract_class] || {}
        end

        # Get all registered types as hash (for as_json output)
        #
        # @return [Hash] { global_types: {...}, local_types_by_contract: {...} }
        def all_types_for_json
          {
            global_types: global_types.keys,
            local_types_by_contract: local_types.transform_values { |types| types.keys }
          }
        end

        # Serialize global types for as_json output
        # Returns expanded type definitions with all fields
        #
        # @return [Hash] { type_name => type_definition }
        def serialize_global_types
          result = {}
          global_types.each do |type_name, definition|
            # Expand the type definition by calling the block in a serialization context
            result[type_name] = expand_type_definition(definition)
          end
          result
        end

        # Serialize local types for a specific contract for as_json output
        # Returns expanded type definitions with all fields using qualified names
        #
        # @param contract_class [Class] Contract class
        # @return [Hash] { qualified_type_name => type_definition }
        def serialize_local_types(contract_class)
          result = {}
          types = local_types[contract_class] || {}

          # Convert to array first to avoid "can't add a new key into hash during iteration"
          # This happens when expanding a type triggers registration of nested types
          types_array = types.to_a

          types_array.each do |_type_name, metadata|
            qualified_name = metadata[:qualified_name]
            definition = metadata[:definition]

            # Expand the type definition by calling the block in a serialization context
            result[qualified_name] = expand_type_definition(definition)
          end

          result
        end

        # Serialize ALL types for an API's as_json output
        # Returns a single hash with all global types + all local types from all contracts
        #
        # @param api [Apiwork::API::Base] The API instance
        # @return [Hash] { type_name => type_definition }
        def serialize_all_types_for_api(api)
          result = {}

          # Add all global types (no prefix)
          # Convert to array to avoid iteration issues if new types are registered during expansion
          global_types.to_a.each do |type_name, definition|
            result[type_name] = expand_type_definition(definition)
          end

          # Add all local types from all contracts (prefixed)
          # Convert to array TWICE (both levels) to prevent "can't add a new key into hash during iteration" errors
          # This allows new types to be registered during expansion without affecting iteration
          local_types.to_a.each do |contract_class, types|
            types.to_a.each do |_type_name, metadata|
              qualified_name = metadata[:qualified_name]
              definition = metadata[:definition]

              result[qualified_name] = expand_type_definition(definition)
            end
          end

          result
        end

        # Serialize ALL enums for an API's as_json output
        # Returns a single hash with all global enums + all local enums from all scopes
        #
        # @param api [Apiwork::API::Base] The API instance
        # @return [Hash] { enum_name => values_array }
        def serialize_all_enums_for_api(api)
          result = {}

          # Add all global enums (no prefix)
          global_enums.each do |enum_name, values|
            result[enum_name] = values
          end

          # Add all local enums from all scopes (prefixed)
          # Convert to array to prevent iteration issues
          local_enums.to_a.each do |scope, enums|
            enums.to_a.each do |_enum_name, metadata|
              qualified_name = metadata[:qualified_name]
              values = metadata[:values]

              result[qualified_name] = values
            end
          end

          result
        end

        # Clear all registered types and enums (useful for testing)
        def clear!
          @global_types = {}
          @local_types = {}
          @global_enums = {}
          @local_enums = {}
        end

        private

        # Expand a type definition block to extract its structure
        # Evaluates the block in a definition context and returns the serialized params
        #
        # @param definition [Proc] The type definition block
        # @return [Hash] Serialized type definition
        def expand_type_definition(definition)
          # Create a minimal anonymous contract class to satisfy Definition constructor
          temp_contract = Class.new(Apiwork::Contract::Base)
          temp_definition = Apiwork::Contract::Definition.new(:input, temp_contract)

          # Evaluate the block in the context of the definition
          temp_definition.instance_eval(&definition)

          # Return the serialized definition
          temp_definition.as_json
        end

        # Storage for global types
        def global_types
          @global_types ||= {}
        end

        # Storage for local types
        # Structure: { ContractClass => { type_name => metadata } }
        def local_types
          @local_types ||= {}
        end

        # Storage for global enums
        # Structure: { enum_name => values_array }
        def global_enums
          @global_enums ||= {}
        end

        # Storage for local enums
        # Structure: { scope_key => { enum_name => metadata } }
        # scope_key can be:
        #   - Contract class (for contract-level enums)
        #   - Definition instance (for action/input/output-level enums)
        def local_enums
          @local_enums ||= {}
        end

        # Extract contract prefix from contract class name
        #
        # @param contract_class [Class] Contract class
        # @return [String] Prefix for qualified names
        #
        # @example
        #   extract_contract_prefix(InvoiceContract)
        #   # => "invoice"
        #
        #   extract_contract_prefix(Api::V1::PaymentContract)
        #   # => "payment"
        def extract_contract_prefix(contract_class)
          # ALWAYS prefer schema's root_key if available (for consistency)
          # This ensures AccountContract with AccountSchema both use "account" prefix
          # instead of getting "account" from schema and "account" from contract name
          if contract_class.respond_to?(:schema_class)
            schema_class = contract_class.schema_class
            return schema_class.root_key.singular if schema_class
          end

          # Handle anonymous classes without schema
          if contract_class.name.nil?
            # Fallback: use object_id for anonymous classes without schema
            return "anonymous_#{contract_class.object_id}"
          end

          # Extract from contract class name (for contracts without schemas)
          contract_class.name
                        .demodulize           # InvoiceContract
                        .underscore           # invoice_contract
                        .gsub(/_contract$/, '') # invoice
        end
      end
    end
  end
end
