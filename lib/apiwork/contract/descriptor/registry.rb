# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptor
      class Registry
        class << self
          def register_type(name, scope: nil, api_class: nil, &block)
            TypeStore.register_type(name, scope: scope, api_class: api_class, &block)
          end

          def register_enum(name, values, scope: nil, api_class: nil)
            EnumStore.register_enum(name, values, scope: scope, api_class: api_class)
            # Auto-generate enum filter type
            register_enum_filter_type(enum_name: name, scope: scope, api_class: api_class)
          end

          def register_union(name, data, scope: nil, api_class: nil)
            TypeStore.register_union(name, data, scope: scope, api_class: api_class)
          end

          def resolve(name, contract_class:, api_class: nil, scope: nil)
            TypeStore.resolve(name, contract_class: contract_class, api_class: api_class, scope: scope)
          end

          def qualified_name(contract_class, name)
            TypeStore.qualified_name(contract_class, name)
          end

          def serialize_all_types_for_api(api)
            TypeStore.serialize_all_for_api(normalize_api(api))
          end

          private

          # Auto-generate filter type for an enum
          # Creates a union type: enum value OR object with eq and in fields
          def register_enum_filter_type(enum_name:, scope:, api_class: nil)
            filter_name = :"#{enum_name}_filter"

            # Create union definition programmatically
            # We need to pass a contract class for type resolution in variant blocks
            contract_class = scope || Class.new(Apiwork::Contract::Base)
            union_def = Apiwork::Contract::UnionDefinition.new(contract_class)

            # Add variant 1: the enum itself
            union_def.variant(type: enum_name)

            # Add variant 2: partial object with eq and in fields (all fields optional via .partial())
            union_def.variant(type: :object, partial: true) do
              param :eq, type: enum_name
              param :in, type: :array, of: enum_name
            end

            # Serialize the union definition
            union_data = union_def.serialize

            TypeStore.register_union(filter_name, union_data, scope: scope, api_class: api_class)
          end

          public

          def resolve_enum(name, scope:, api_class: nil)
            EnumStore.resolve(name, scope: scope, api_class: api_class)
          end

          def serialize_all_enums_for_api(api)
            EnumStore.serialize_all_for_api(normalize_api(api))
          end

          def clear!
            TypeStore.clear!
            EnumStore.clear!
          end

          private

          def normalize_api(api)
            api.is_a?(String) ? API::Registry.find(api) : api
          end
        end
      end
    end
  end
end
