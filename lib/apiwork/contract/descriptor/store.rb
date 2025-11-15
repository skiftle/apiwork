# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptor
      class Store
        class << self
          def register(name, payload, scope: nil, metadata: {}, api_class: nil)
            if scope
              # Scoped registration (contract-level, gets prefix)
              storage = api_class ? api_local_storage(api_class) : local_storage
              storage[scope] ||= {}
              storage[scope][name] = {
                short_name: name,
                qualified_name: qualified_name(scope, name),
                payload: payload
              }.merge(metadata)
            else
              # Shared registration (no prefix)
              storage = api_class ? api_storage(api_class) : global_storage

              if storage.key?(name)
                scope_desc = api_class ? "for API #{api_class}" : 'shared'
                raise ArgumentError, "#{storage_name.to_s.singularize.capitalize} :#{name} already registered #{scope_desc}"
              end

              storage[name] = payload
            end
          end

          # Unified resolve implementation for both types and enums
          # Subclasses specify what key to extract from metadata (:definition or :values)
          # Supports imports: types/enums prefixed with import alias (e.g., :user_address)
          def resolve(name, contract_class: nil, api_class: nil, scope: nil, visited_contracts: Set.new)
            # Get contract from scope if available
            contract = scope&.contract_class || contract_class

            # Check for circular imports
            raise ConfigurationError, "Circular import detected while resolving :#{name}" if contract && visited_contracts.include?(contract)

            visited_contracts = visited_contracts.dup.add(contract) if contract

            # 1. Check API-local storage (contract-specific within API)
            if api_class && contract
              api_local = api_local_storage(api_class)[contract]&.[](name)
              return extract_payload_value(api_local) if api_local
            end

            # 2. Check contract class local storage (legacy fallback)
            return extract_payload_value(local_storage[contract][name]) if contract && local_storage[contract]&.key?(name)

            # 2.5. Check schema class storage (fallback for when different contract instances exist)
            # This handles cases where enums are registered on schema class to work across anonymous and explicit contracts
            if api_class && contract.respond_to?(:schema_class) && contract.schema_class
              schema_class = contract.schema_class
              api_local_schema = api_local_storage(api_class)[schema_class]&.[](name)
              return extract_payload_value(api_local_schema) if api_local_schema
            end

            # Also check legacy storage for schema class
            if contract.respond_to?(:schema_class) && contract.schema_class
              schema_class = contract.schema_class
              return extract_payload_value(local_storage[schema_class][name]) if local_storage[schema_class]&.key?(name)
            end

            # 3. Check imports for prefixed types (e.g., :user_address where :user is import alias)
            if contract.respond_to?(:imports)
              contract.imports.each do |import_alias, imported_contract|
                # Check if type name starts with import alias prefix
                prefix = "#{import_alias}_"
                next unless name.to_s.start_with?(prefix)

                # Extract the actual type name without prefix
                imported_type_name = name.to_s.sub(prefix, '').to_sym

                # Recursively resolve from imported contract
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

            # 4. Check API-global storage (shared within API)
            return api_storage(api_class)[name] if api_class && api_storage(api_class).key?(name)

            # 5. Check global storage (legacy fallback)
            global_storage[name]
          end

          def qualified_name(scope, name)
            return name unless scope

            # Handle contract class scope (both Class and instances with contract_class)
            contract_class = scope.is_a?(Class) ? scope : scope.contract_class

            contract_prefix = extract_contract_prefix(contract_class)
            return contract_prefix.to_sym if name.nil? || name.to_s.empty?

            # If name already equals the prefix, don't duplicate
            return name.to_sym if name.to_s == contract_prefix

            :"#{contract_prefix}_#{name}"
          end

          def clear!
            instance_variable_set("@global_#{storage_name}", {})
            instance_variable_set("@local_#{storage_name}", {})
            instance_variable_set("@api_#{storage_name}", {})
            instance_variable_set("@api_local_#{storage_name}", {})
          end

          def clear_local!
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
            api_key = api_class.respond_to?(:path) ? api_class.path : api_class
            all_api_storages[api_key] ||= {}
          end

          def api_local_storage(api_class)
            all_api_local_storages = instance_variable_get("@api_local_#{storage_name}") ||
                                     instance_variable_set("@api_local_#{storage_name}", {})
            # Use API path as key instead of API instance to survive code reloading
            api_key = api_class.respond_to?(:path) ? api_class.path : api_class
            all_api_local_storages[api_key] ||= {}
          end
        end
      end
    end
  end
end
