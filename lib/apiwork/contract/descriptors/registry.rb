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

          def resolve(name, contract_class:, scope: nil)
            TypeStore.resolve(name, contract_class: contract_class, scope: scope)
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
            # Auto-generate enum filter type
            register_enum_filter_type(name, is_global: true)
          end

          def register_local_enum(scope, name, values)
            EnumStore.register_local(scope, name, values)
            # Auto-generate enum filter type
            register_enum_filter_type(name, is_global: false, scope: scope)
          end

          private

          # Auto-generate filter type for an enum
          # Creates a union type: enum value OR object with eq and in fields
          def register_enum_filter_type(enum_name, is_global:, scope: nil)
            filter_name = :"#{enum_name}_filter"

            # Create union definition programmatically
            # We need to pass a contract class for type resolution in variant blocks
            contract_class = is_global ? Class.new(Apiwork::Contract::Base) : scope
            union_def = Apiwork::Contract::UnionDefinition.new(contract_class)

            # Add variant 1: the enum itself
            union_def.variant(type: enum_name)

            # Add variant 2: object with eq and in fields (all fields required, but object will be partial)
            union_def.variant(type: :object) do
              param :eq, type: enum_name, required: true
              param :in, type: :array, of: enum_name, required: true
            end

            # Serialize the union definition
            union_data = union_def.serialize

            # Mark the object variant as partial (all fields should be optional in Zod)
            union_data[:variants][1][:partial] = true if union_data[:variants].is_a?(Array) && union_data[:variants][1]

            if is_global
              TypeStore.register_global_union(filter_name, union_data)
            else
              TypeStore.register_local_union(scope, filter_name, union_data)
            end
          end

          public

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
