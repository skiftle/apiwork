# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptor
      class Registry
        class << self
          def register_type(name, scope: nil, api_class: nil, description: nil, example: nil, format: nil, deprecated: false, &block)
            TypeStore.register_type(
              name,
              scope: scope,
              api_class: api_class,
              description: description,
              example: example,
              format: format,
              deprecated: deprecated,
              &block
            )
          end

          def register_enum(name, values, scope: nil, api_class: nil, description: nil, example: nil, deprecated: false)
            EnumStore.register_enum(
              name,
              values,
              scope: scope,
              api_class: api_class,
              description: description,
              example: example,
              deprecated: deprecated
            )
            # Auto-generate enum filter type
            register_enum_filter_type(enum_name: name, scope: scope, api_class: api_class)
          end

          def register_union(name, data, scope: nil, api_class: nil)
            TypeStore.register_union(name, data, scope: scope, api_class: api_class)
          end

          def resolve_type(name, contract_class:, api_class: nil, scope: nil)
            TypeStore.resolve(name, contract_class: contract_class, api_class: api_class, scope: scope)
          end

          def scoped_name(contract_class, name)
            TypeStore.scoped_name(contract_class, name)
          end

          def types(api)
            TypeStore.serialize(normalize_api(api))
          end

          private

          # Auto-generate filter type for an enum
          # Creates a union type: enum value OR object with eq and in fields
          def register_enum_filter_type(enum_name:, scope:, api_class: nil)
            # Get the scoped enum name (e.g., :kind → :client_kind)
            scoped_enum_name = EnumStore.scoped_name(scope, enum_name)
            filter_name = :"#{enum_name}_filter"

            # Create union definition programmatically
            # We need to pass a contract class for type resolution in variant blocks
            contract_class = scope || Class.new(Apiwork::Contract::Base)
            union_definition = Apiwork::Contract::UnionDefinition.new(contract_class)

            # Add variant 1: the enum itself (use scoped name)
            union_definition.variant(type: scoped_enum_name)

            # Add variant 2: partial object with eq and in fields (all fields optional via .partial())
            union_definition.variant(type: :object, partial: true) do
              param :eq, type: scoped_enum_name
              param :in, type: :array, of: scoped_enum_name
            end

            # Serialize the union definition
            union_data = union_definition.serialize

            TypeStore.register_union(filter_name, union_data, scope: scope, api_class: api_class)
          end

          public

          def resolve_enum(name, scope:, api_class: nil)
            EnumStore.resolve(name, scope: scope, api_class: api_class)
          end

          def enums(api)
            EnumStore.serialize(normalize_api(api))
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
