# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptor
      class GlobalBuilder
        def initialize(api_class: nil)
          @api_class = api_class
        end

        def type(name, **_options, &block)
          Registry.register_type(name, api_class: @api_class, &block)
        end

        def enum(name, values)
          raise ArgumentError, 'Values array required for enum definition' unless values.is_a?(Array)

          Registry.register_enum(name, values, api_class: @api_class)
        end

        def union(name, &block)
          raise ArgumentError, 'Union type requires a block with variant definitions' unless block_given?

          # Create a union definition using the provided block
          union_def = UnionDefinition.new(nil)
          union_def.instance_eval(&block)

          # Serialize the union definition
          union_data = union_def.serialize

          Registry.register_union(name, union_data, api_class: @api_class)
        end
      end
    end
  end
end
