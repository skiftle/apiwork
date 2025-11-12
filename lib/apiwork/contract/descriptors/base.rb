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
          def resolve(name, contract_class: nil, scope: nil)
            # Get contract from scope if available
            contract = scope&.contract_class || contract_class

            # Check contract class
            return extract_payload_value(local_storage[contract][name]) if contract && local_storage[contract]&.key?(name)

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
            if contract_class.respond_to?(:schema_class)
              schema_class = contract_class.schema_class
              return schema_class.root_key.singular if schema_class
            end

            return "anonymous_#{contract_class.object_id}" if contract_class.name.nil?

            contract_class.name
                          .demodulize
                          .underscore
                          .gsub(/_contract$/, '')
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
