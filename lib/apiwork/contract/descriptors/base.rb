# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptors
      class Base
        class << self
          def register_global(name, payload)
            raise ArgumentError, "Global #{storage_name.to_s.singularize} :#{name} already registered" if global_storage.key?(name)

            global_storage[name] = payload
          end

          def register_local(scope, name, payload, metadata = {})
            local_storage[scope] ||= {}
            local_storage[scope][name] = {
              short_name: name,
              qualified_name: qualified_name(scope, name),
              payload: payload
            }.merge(metadata)
          end

          def global?(name)
            global_storage.key?(name)
          end

          def local?(name, scope)
            local_storage[scope]&.key?(name) || false
          end

          # Unified resolve implementation for both types and enums
          # Subclasses specify what key to extract from metadata (:definition or :values)
          # Supports imports: types/enums prefixed with import alias (e.g., :user_address)
          def resolve(name, contract_class: nil, scope: nil, visited_contracts: Set.new)
            # Get contract from scope if available
            contract = scope&.contract_class || contract_class

            # Check for circular imports
            raise ConfigurationError, "Circular import detected while resolving :#{name}" if contract && visited_contracts.include?(contract)

            visited_contracts = visited_contracts.dup.add(contract) if contract

            # Check contract class local storage
            return extract_payload_value(local_storage[contract][name]) if contract && local_storage[contract]&.key?(name)

            # Check imports for prefixed types (e.g., :user_address where :user is import alias)
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
                  scope: nil,
                  visited_contracts: visited_contracts
                )

                return result if result
              end
            end

            # Check global
            global_storage[name]
          end

          def qualified_name(scope, name)
            return name if global?(name)

            # Handle contract class scope (both Class and instances with contract_class)
            contract_class = scope.is_a?(Class) ? scope : scope.contract_class

            contract_prefix = extract_contract_prefix(contract_class)
            return contract_prefix.to_sym if name.nil? || name.to_s.empty?

            :"#{contract_prefix}_#{name}"
          end

          def clear!
            instance_variable_set("@global_#{storage_name}", {})
            instance_variable_set("@local_#{storage_name}", {})
          end

          def clear_local!
            instance_variable_set("@local_#{storage_name}", {})
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
                                   .gsub(/_contract$/, '')
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
        end
      end
    end
  end
end
