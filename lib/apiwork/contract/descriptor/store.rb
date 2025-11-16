# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptor
      class Store
        class << self
          def register(name, payload, scope: nil, metadata: {}, api_class: nil)
            # Unified storage: all types/enums in one place with scope metadata
            # scope: nil → unprefixed (API-global like :page, :string_filter)
            # scope: ContractClass → prefixed (contract-scoped like :post_status)

            store = storage(api_class)
            scoped_name_value = scope ? scoped_name(scope, name) : name

            # Allow idempotent re-registration for Rails reloading
            store[scoped_name_value] = {
              name: name,
              scoped_name: scoped_name_value,
              scope: scope,
              payload: payload
            }.merge(metadata)
          end

          # Unified resolve implementation for both types and enums
          # Simplified: 2 steps instead of 6
          def resolve(name, contract_class: nil, api_class: nil, scope: nil, visited_contracts: Set.new)
            # Get contract from scope if available
            contract = scope&.contract_class || contract_class

            # Check for circular imports
            raise ConfigurationError, "Circular import detected while resolving :#{name}" if contract && visited_contracts.include?(contract)

            visited_contracts = visited_contracts.dup.add(contract) if contract

            store = storage(api_class)

            # 1. Try scoped name (with contract prefix)
            if contract
              scoped_name_value = scoped_name(contract, name)
              return resolved_value(store[scoped_name_value]) if store.key?(scoped_name_value)
            end

            # 2. Check imports for prefixed types (e.g., :user_address → UserContract)
            if contract.respond_to?(:imports)
              contract.imports.each do |import_alias, imported_contract|
                prefix = "#{import_alias}_"
                next unless name.to_s.start_with?(prefix)

                imported_type_name = name.to_s.sub(prefix, '').to_sym
                result = resolve(
                  imported_type_name,
                  contract_class: imported_contract,
                  api_class: api_class,
                  scope: nil,
                  visited_contracts: visited_contracts
                )
                return result if result
              end
            end

            # 3. Try unprefixed (API-global like :page, :string_filter)
            return resolved_value(store[name]) if store.key?(name)

            # Type/enum not found
            nil
          end

          def scoped_name(scope, name)
            return name unless scope

            # Handle contract class scope (both Class and instances with contract_class)
            contract_class = scope.is_a?(Class) ? scope : scope.contract_class

            begin
              contract_prefix = scope_prefix(contract_class)
            rescue ConfigurationError
              # Anonymous contract without schema/identifier - can't create prefix
              # This is OK for resolve (we'll just try unprefixed), but error for register
              return name
            end

            return contract_prefix.to_sym if name.nil? || name.to_s.empty?

            # If name already equals the prefix, don't duplicate
            return name.to_sym if name.to_s == contract_prefix

            :"#{contract_prefix}_#{name}"
          end

          def clear!
            @storage = {}
          end

          def clear_local!
            @storage = {}
          end

          def serialize(api)
            raise NotImplementedError, 'Subclasses must implement serialize'
          end

          protected

          # Subclasses implement this to return the resolved value for this store type
          # TypeStore returns metadata[:definition]
          # EnumStore returns metadata[:values]
          def resolved_value(metadata)
            raise NotImplementedError, 'Subclasses must implement resolved_value'
          end

          def scope_prefix(contract_class)
            # 1. Explicit identifier (highest priority - developer choice)
            return contract_class._identifier if contract_class.respond_to?(:_identifier) && contract_class._identifier

            # 2. Schema root_key (fallback if no identifier)
            return contract_class.schema_class.root_key.singular if contract_class.respond_to?(:schema_class) && contract_class.schema_class

            # 3. Class name
            if contract_class.name
              return contract_class.name
                                   .demodulize
                                   .underscore
                                   .gsub(/_(contract|schema)$/, '')
            end

            # 4. Error - require explicit naming
            raise ConfigurationError,
                  'Anonymous contract must have a schema or explicit identifier. ' \
                  "Use: identifier 'resource_name' or schema YourSchema"
          end

          def storage_name
            raise NotImplementedError, 'Subclasses must implement storage_name'
          end

          # Unified storage: single hash with scope metadata
          def storage(api_class)
            @storage ||= {}
            api_key = api_class.respond_to?(:mount_path) ? api_class.mount_path : api_class
            @storage[api_key] ||= {}
          end
        end
      end
    end
  end
end
