# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptor
      class Builder
        def initialize(api_class: nil, scope: nil)
          @api_class = api_class
          @scope = scope # nil = global, ContractClass = contract-scoped
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

        def enum(name, *args, values: nil, description: nil, example: nil, deprecated: false)
          unless args.empty?
            raise ArgumentError,
                  "Invalid enum syntax. Use 'enum :#{name}, values: #{args.first.inspect}' " \
                  '(values must be a keyword argument)'
          end

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
