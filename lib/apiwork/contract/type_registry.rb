# frozen_string_literal: true

module Apiwork
  module Contract
    # TypeRegistry: Centralized storage for all custom types
    #
    # Manages two categories of types:
    # 1. Global types - Shared across all contracts (e.g., string_filter, page_params)
    # 2. Local types - Scoped to specific contracts (e.g., InvoiceContract's :filter)
    #
    # Global types are registered via Apiwork.register_global_types
    # Local types are registered when Contract classes define types
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
          global_types.each do |type_name, definition|
            result[type_name] = expand_type_definition(definition)
          end

          # Add all local types from all contracts (prefixed)
          local_types.each do |contract_class, types|
            types_array = types.to_a

            types_array.each do |_type_name, metadata|
              qualified_name = metadata[:qualified_name]
              definition = metadata[:definition]

              result[qualified_name] = expand_type_definition(definition)
            end
          end

          result
        end

        # Clear all registered types (useful for testing)
        def clear!
          @global_types = {}
          @local_types = {}
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
