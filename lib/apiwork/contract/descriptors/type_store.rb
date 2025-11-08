# frozen_string_literal: true


module Apiwork
  module Contract
    module Descriptors
      # TypeStore handles custom type registration and resolution
      # Types are stored as Proc blocks that define parameter structures
      class TypeStore < Base
        class << self
          # Register a global type (shared across all contracts)
          #
          # @param name [Symbol] Type name (e.g., :string_filter)
          # @param block [Proc] Type definition block
          # @raise [ArgumentError] if type already registered
          def register_global(name, &block)
            super(name, block)
          end

          # Register a local type (scoped to a contract)
          #
          # @param contract_class [Class] Contract class defining this type
          # @param name [Symbol] Short type name (e.g., :filter)
          # @param block [Proc] Type definition block
          def register_local(contract_class, name, &block)
            super(contract_class, name, block, { definition: block })
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
            if local_storage[contract_class]&.key?(name)
              return local_storage[contract_class][name][:definition]
            end

            # Fall back to global types
            global_storage[name]
          end

          # Get qualified name for a type (used in as_json output)
          #
          # Global types keep their name
          # Local types get prefixed with contract name
          #
          # @param contract_class_or_scope [Class, Object] Contract class or scope object
          # @param name [Symbol] Short type name
          # @return [Symbol] Qualified type name
          #
          # @example
          #   qualified_name(InvoiceContract, :filter)
          #   # => :invoice_filter
          #
          #   qualified_name(InvoiceContract, :string_filter)  # global type
          #   # => :string_filter
          def qualified_name(contract_class_or_scope, name)
            # Extract contract class if scope is a Definition or ActionDefinition
            contract_class = if contract_class_or_scope.respond_to?(:contract_class)
                              contract_class_or_scope.contract_class
                            else
                              contract_class_or_scope
                            end

            # Global types keep their name
            return name if global?(name)

            # Local types get contract prefix
            contract_prefix = extract_contract_prefix(contract_class)

            # Special case: nil name means just use the prefix (for resource types)
            return contract_prefix.to_sym if name.nil? || name.to_s.empty?

            :"#{contract_prefix}_#{name}"
          end

          # Serialize ALL types for an API's as_json output
          # Returns a single hash with all global types + all local types from all contracts
          #
          # @param api [Apiwork::API::Base] The API instance
          # @return [Hash] { type_name => type_definition }
          def serialize_all_for_api(api)
            result = {}

            # Add all global types (no prefix)
            # Convert to array to avoid iteration issues if new types are registered during expansion
            global_storage.to_a.each do |type_name, definition|
              result[type_name] = expand_type_definition(definition, contract_class: nil)
            end

            # Add all local types from all contracts (prefixed)
            # Convert to array TWICE (both levels) to prevent "can't add a new key into hash during iteration" errors
            # This allows new types to be registered during expansion without affecting iteration
            local_storage.to_a.each do |contract_class, types|
              types.to_a.each do |_type_name, metadata|
                qualified_type_name = metadata[:qualified_name]
                definition = metadata[:definition]

                result[qualified_type_name] = expand_type_definition(definition, contract_class: contract_class)
              end
            end

            result
          end

          protected

          def storage_name
            :types
          end

          private

          # Expand a type definition block to extract its structure
          # Evaluates the block in a definition context and returns the serialized params
          #
          # @param definition [Proc] The type definition block
          # @param contract_class [Class, nil] Optional contract class for enum resolution
          # @return [Hash] Serialized type definition
          def expand_type_definition(definition, contract_class: nil)
            # Use provided contract class or create a minimal anonymous one
            # Using the real contract class allows enum resolution to work
            temp_contract = contract_class || Class.new(Apiwork::Contract::Base)
            temp_definition = Apiwork::Contract::Definition.new(:input, temp_contract)

            # Evaluate the block in the context of the definition
            temp_definition.instance_eval(&definition)

            # Return the serialized definition
            temp_definition.as_json
          end
        end
      end
    end
  end
end
