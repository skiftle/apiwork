# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptors
      class GlobalBuilder
        def type(name, **_options, &block)
          Registry.register_global(name, &block)
        end

        def enum(name, values)
          raise ArgumentError, 'Values array required for enum definition' unless values.is_a?(Array)

          Registry.register_global_enum(name, values)
        end

        def union(name, &block)
          raise ArgumentError, 'Union type requires a block with variant definitions' unless block_given?

          # Create a union definition using the provided block
          union_def = UnionDefinition.new(nil)
          union_def.instance_eval(&block)

          # Serialize the union to a data structure
          union_data = {
            _union: {
              type: :union,
              required: false,
              nullable: false,
              variants: union_def.variants,
              discriminator: union_def.discriminator
            }.compact # Remove nil discriminator if not set
          }

          TypeStore.register_global_union(name, union_data)
        end
      end
    end
  end
end
