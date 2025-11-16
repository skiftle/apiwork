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
            qualified = scope ? qualified_name(scope, name) : name

            # Allow idempotent re-registration for Rails reloading
            store[qualified] = {
              short_name: name,
              qualified_name: qualified,
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

            # 1. Try qualified name (with contract prefix)
            if contract
              qualified = qualified_name(contract, name)
              return extract_payload_value(store[qualified]) if store.key?(qualified)
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
            return extract_payload_value(store[name]) if store.key?(name)

            # 4. Legacy fallback (will be removed in future)
            legacy_resolve(name, contract, api_class)
          end

          def qualified_name(scope, name)
            return name unless scope

            # Handle contract class scope (both Class and instances with contract_class)
            contract_class = scope.is_a?(Class) ? scope : scope.contract_class

            begin
              contract_prefix = extract_contract_prefix(contract_class)
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
            # Clear unified storage
            @storage = {}
            # Also clear legacy storage for backward compatibility
            instance_variable_set("@global_#{storage_name}", {})
            instance_variable_set("@local_#{storage_name}", {})
            instance_variable_set("@api_#{storage_name}", {})
            instance_variable_set("@api_local_#{storage_name}", {})
          end

          def clear_local!
            # Clear unified storage
            @storage = {}
            # Also clear legacy storage for backward compatibility
            instance_variable_set("@local_#{storage_name}", {})
            instance_variable_set("@api_local_#{storage_name}", {})
          end

          def all_global
            global_storage.keys
          end

          def all_local(scope)
            local_storage[scope] || {}
          end

          def serialize_all_for_api(api)
            raise NotImplementedError, 'Subclasses must implement serialize_all_for_api'
          end

          protected

          def legacy_resolve(name, contract, api_class)
            # Legacy storage fallback - for backward compatibility during migration
            # This ensures existing code continues to work while we migrate to unified storage

            # Check old api_local_storage
            if api_class && contract
              api_local = api_local_storage(api_class)[contract]&.[](name)
              return extract_payload_value(api_local) if api_local

              # Schema class fallback
              if contract.respond_to?(:schema_class) && contract.schema_class
                schema_class = contract.schema_class
                api_local_schema = api_local_storage(api_class)[schema_class]&.[](name)
                return extract_payload_value(api_local_schema) if api_local_schema
              end
            end

            # Check old local_storage
            return extract_payload_value(local_storage[contract][name]) if contract && local_storage[contract]&.key?(name)

            # Check schema in local_storage
            if contract.respond_to?(:schema_class) && contract.schema_class
              schema_class = contract.schema_class
              return extract_payload_value(local_storage[schema_class][name]) if local_storage[schema_class]&.key?(name)
            end

            # Check old api_storage
            return api_storage(api_class)[name] if api_class && api_storage(api_class).key?(name)

            # Check old global_storage
            global_storage[name]
          end

          # Subclasses implement this to specify which key to extract
          # TypeStore returns metadata[:definition]
          # EnumStore returns metadata[:values]
          def extract_payload_value(metadata)
            raise NotImplementedError, 'Subclasses must implement extract_payload_value'
          end

          def extract_contract_prefix(contract_class)
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

          # Legacy storage methods (kept for backward compatibility during migration)
          def global_storage
            instance_variable_get("@global_#{storage_name}") ||
              instance_variable_set("@global_#{storage_name}", {})
          end

          def local_storage
            instance_variable_get("@local_#{storage_name}") ||
              instance_variable_set("@local_#{storage_name}", {})
          end

          def api_storage(api_class)
            all_api_storages = instance_variable_get("@api_#{storage_name}") ||
                               instance_variable_set("@api_#{storage_name}", {})
            # Use API path as key instead of API instance to survive code reloading
            api_key = api_class.respond_to?(:mount_path) ? api_class.mount_path : api_class
            all_api_storages[api_key] ||= {}
          end

          def api_local_storage(api_class)
            all_api_local_storages = instance_variable_get("@api_local_#{storage_name}") ||
                                     instance_variable_set("@api_local_#{storage_name}", {})
            # Use API path as key instead of API instance to survive code reloading
            api_key = api_class.respond_to?(:mount_path) ? api_class.mount_path : api_class
            all_api_local_storages[api_key] ||= {}
          end
        end
      end
    end
  end
end
