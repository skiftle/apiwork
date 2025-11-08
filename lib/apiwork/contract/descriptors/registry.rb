# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptors
      class Registry
        class << self
          def register_global(name, &block)
            TypeStore.register_global(name, &block)
          end

          def register_local(contract_class, name, &block)
            TypeStore.register_local(contract_class, name, &block)
          end

          def resolve(name, contract_class:)
            TypeStore.resolve(name, contract_class: contract_class)
          end

          def global?(name)
            TypeStore.global?(name)
          end

          def local?(name, contract_class)
            TypeStore.local?(name, contract_class)
          end

          def qualified_name(contract_class, name)
            TypeStore.qualified_name(contract_class, name)
          end

          def all_global_types
            TypeStore.all_global
          end

          def all_local_types(contract_class)
            TypeStore.all_local(contract_class)
          end

          def serialize_all_types_for_api(api)
            TypeStore.serialize_all_for_api(api)
          end

          def register_global_enum(name, values)
            EnumStore.register_global(name, values)
          end

          def register_local_enum(scope, name, values)
            EnumStore.register_local(scope, name, values)
          end

          def resolve_enum(name, scope:)
            EnumStore.resolve(name, scope: scope)
          end

          def global_enum?(name)
            EnumStore.global?(name)
          end

          def local_enum?(name, scope)
            EnumStore.local?(name, scope)
          end

          def qualified_enum_name(scope, name)
            EnumStore.qualified_name(scope, name)
          end

          def serialize_all_enums_for_api(api)
            EnumStore.serialize_all_for_api(api)
          end

          def clear!
            TypeStore.clear!
            EnumStore.clear!
          end

          def all_for_json
            {
              global_types: TypeStore.all_global,
              global_enums: EnumStore.all_global
            }
          end
        end
      end
    end
  end
end
