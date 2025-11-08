# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptors
      class Base
        class << self
          def register_global(name, payload)
            if global_storage.key?(name)
              raise ArgumentError, "Global #{descriptor_type} :#{name} already registered"
            end

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

          def qualified_name(scope, name)
            raise NotImplementedError, "Subclasses must implement qualified_name"
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
            raise NotImplementedError, "Subclasses must implement serialize_all_for_api"
          end

          protected

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
            raise NotImplementedError, "Subclasses must implement storage_name"
          end

          def descriptor_type
            storage_name.to_s.singularize
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
