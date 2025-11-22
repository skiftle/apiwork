# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptor
      class Builder
        def initialize(api_class: nil, scope: nil)
          @api_class = api_class
          @scope = scope # nil = global, ContractClass = contract-scoped
        end

        def self.define_type(api_class:, name:, scope: nil, description: nil, example: nil, format: nil, deprecated: false, &block)
          raise ArgumentError, 'Block required for type definition' unless block_given?

          builder = new(api_class: api_class, scope: scope)
          builder.type(name, description: description, example: example, format: format, deprecated: deprecated, &block)
        end

        def self.define_enum(api_class:, name:, values:, scope: nil, description: nil, example: nil, deprecated: false)
          builder = new(api_class: api_class, scope: scope)
          builder.enum(name, values: values, description: description, example: example, deprecated: deprecated)
        end

        def self.define_union(api_class:, name:, scope: nil, &block)
          raise ArgumentError, 'Union type requires a block' unless block_given?

          builder = new(api_class: api_class, scope: scope)
          builder.union(name, &block)
        end

        def type(name, description: nil, example: nil, format: nil, deprecated: false, &block)
          raise ArgumentError, 'Block required for type definition' unless block_given?

          Registry.register_type(
            name,
            scope: @scope,
            api_class: @api_class,
            description: description,
            example: example,
            format: format,
            deprecated: deprecated,
            &block
          )
        end

        def enum(name, values:, description: nil, example: nil, deprecated: false)
          raise ArgumentError, 'Values array required for enum definition' if values.nil? || !values.is_a?(Array)

          Registry.register_enum(
            name,
            values,
            scope: @scope,
            api_class: @api_class,
            description: description,
            example: example,
            deprecated: deprecated
          )
        end

        def union(name, &block)
          raise ArgumentError, 'Union type requires a block' unless block_given?

          union_definition = UnionDefinition.new(@scope)
          union_definition.instance_eval(&block)
          union_data = union_definition.serialize

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
