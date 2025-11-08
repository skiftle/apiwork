# frozen_string_literal: true

module Apiwork
  module Contract
    module DescriptorRegistry
      # Base class for descriptor stores (types and enums)
      # Contains shared logic for registration, resolution, and serialization
      #
      # Subclasses must implement:
      # - storage_name: Returns symbol (:types or :enums) for storage variable names
      # - serialize_all_for_api(api): Returns serialized hash for API introspection
      class Base
        class << self
          # Register a global descriptor (shared across all contracts)
          #
          # @param name [Symbol] Descriptor name
          # @param payload [Object] Descriptor payload (Proc for types, Array for enums)
          # @raise [ArgumentError] if descriptor already registered
          def register_global(name, payload)
            if global_storage.key?(name)
              raise ArgumentError, "Global #{descriptor_type} :#{name} already registered"
            end

            global_storage[name] = payload
          end

          # Register a local descriptor (scoped to a contract/action/definition)
          #
          # @param scope [Class, Object] Scope object (Contract class or Definition instance)
          # @param name [Symbol] Short descriptor name
          # @param payload [Object] Descriptor payload
          # @param metadata [Hash] Additional metadata (optional)
          def register_local(scope, name, payload, metadata = {})
            local_storage[scope] ||= {}
            local_storage[scope][name] = {
              short_name: name,
              qualified_name: qualified_name(scope, name),
              payload: payload
            }.merge(metadata)
          end

          # Check if a descriptor is registered as global
          #
          # @param name [Symbol] Descriptor name
          # @return [Boolean]
          def global?(name)
            global_storage.key?(name)
          end

          # Check if a descriptor is registered locally for a scope
          #
          # @param name [Symbol] Descriptor name
          # @param scope [Object] Scope object
          # @return [Boolean]
          def local?(name, scope)
            local_storage[scope]&.key?(name) || false
          end

          # Get qualified name for a descriptor (used in as_json output)
          #
          # Must be implemented by subclasses to handle scope-specific naming
          #
          # @param scope [Object] Scope object
          # @param name [Symbol] Short descriptor name
          # @return [Symbol] Qualified descriptor name
          def qualified_name(scope, name)
            raise NotImplementedError, "Subclasses must implement qualified_name"
          end

          # Clear all registered descriptors (useful for testing)
          def clear!
            instance_variable_set("@global_#{storage_name}", {})
            instance_variable_set("@local_#{storage_name}", {})
          end

          # Get all global descriptor names
          #
          # @return [Array<Symbol>] Array of global descriptor names
          def all_global
            global_storage.keys
          end

          # Get all local descriptors for a scope
          #
          # @param scope [Object] Scope object
          # @return [Hash] Hash of {short_name => metadata}
          def all_local(scope)
            local_storage[scope] || {}
          end

          # Serialize ALL descriptors for an API's as_json output
          # Must be implemented by subclasses
          #
          # @param api [Apiwork::API::Base] The API instance
          # @return [Hash] Serialized descriptors
          def serialize_all_for_api(api)
            raise NotImplementedError, "Subclasses must implement serialize_all_for_api"
          end

          protected

          # Extract contract prefix from contract class name
          # Used by both TypeStore and EnumStore for qualified naming
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

          # Get storage name for this descriptor type
          # Must be implemented by subclasses
          #
          # @return [Symbol] Storage name (:types or :enums)
          def storage_name
            raise NotImplementedError, "Subclasses must implement storage_name"
          end

          # Get human-readable descriptor type name
          # Used for error messages
          #
          # @return [String] Descriptor type name ("type" or "enum")
          def descriptor_type
            storage_name.to_s.singularize
          end

          # Storage for global descriptors
          def global_storage
            instance_variable_get("@global_#{storage_name}") ||
              instance_variable_set("@global_#{storage_name}", {})
          end

          # Storage for local descriptors
          # Structure: { scope_key => { descriptor_name => metadata } }
          def local_storage
            instance_variable_get("@local_#{storage_name}") ||
              instance_variable_set("@local_#{storage_name}", {})
          end
        end
      end
    end
  end
end
