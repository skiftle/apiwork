# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptor
      class Builder
        def initialize(api_class: nil, scope: nil)
          @api_class = api_class
          @scope = scope # nil = global, ContractClass = contract-scoped
        end

        def type(name, &block)
          raise ArgumentError, 'Block required for type definition' unless block_given?

          Registry.register_type(
            name,
            scope: @scope,
            api_class: @api_class,
            &block
          )
        end

        def enum(name, values)
          raise ArgumentError, 'Values array required for enum definition' unless values.is_a?(Array)

          Registry.register_enum(
            name,
            values,
            scope: @scope,
            api_class: @api_class
          )
        end

        def union(name, &block)
          raise ArgumentError, 'Union type requires a block' unless block_given?

          union_def = UnionDefinition.new(@scope)
          union_def.instance_eval(&block)
          union_data = union_def.serialize

          Registry.register_union(
            name,
            union_data,
            scope: @scope,
            api_class: @api_class
          )
        end
      end
    end
  end
end
