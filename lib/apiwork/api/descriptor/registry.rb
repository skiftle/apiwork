# frozen_string_literal: true

module Apiwork
  module API
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

          private

          def register_enum_filter_type(enum_name:, scope:, api_class: nil)
            scoped_enum_name = EnumStore.scoped_name(scope, enum_name)
            filter_name = :"#{enum_name}_filter"

            union_builder = UnionBuilder.new
            union_builder.variant(type: scoped_enum_name)
            union_builder.variant(type: :object, partial: true)

            union_data = union_builder.serialize

            union_data[:variants][1][:shape] = build_enum_filter_shape(scoped_enum_name)

            TypeStore.register_union(filter_name, union_data, scope: scope, api_class: api_class)
          end

          def build_enum_filter_shape(enum_type)
            {
              eq: { name: :eq, type: enum_type, required: false },
              in: { name: :in, type: :array, of: enum_type, required: false }
            }
          end

          public

          def resolve_enum(name, scope:, api_class: nil)
            EnumStore.resolve(name, scope: scope, api_class: api_class)
          end

          def types(api)
            Apiwork::Introspection.types(normalize_api(api))
          end

          def enums(api)
            Apiwork::Introspection.enums(normalize_api(api))
          end

          def clear!
            TypeStore.clear!
            EnumStore.clear!
          end

          private

          def normalize_api(api)
            api.is_a?(String) ? Apiwork::API::Registry.find(api) : api
          end
        end
      end
    end
  end
end
