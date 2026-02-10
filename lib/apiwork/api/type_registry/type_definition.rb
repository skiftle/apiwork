# frozen_string_literal: true

module Apiwork
  module API
    class TypeRegistry
      class TypeDefinition
        attr_reader :deprecated,
                    :description,
                    :discriminator,
                    :example,
                    :kind,
                    :name,
                    :scope

        def initialize(
          name,
          kind:,
          scope: nil,
          block: nil,
          deprecated: false,
          description: nil,
          discriminator: nil,
          example: nil
        )
          @name = name
          @kind = kind
          @scope = scope
          @block = block
          @deprecated = deprecated
          @description = description
          @discriminator = discriminator
          @example = example
          @shape = nil
        end

        def deprecated?
          @deprecated == true
        end

        def object?
          @kind == :object
        end

        def union?
          @kind == :union
        end

        def shape
          ensure_shape_built!
          @shape
        end

        def params
          shape.params if object?
        end

        def variants
          shape.variants if union?
        end

        def merge(block:, deprecated:, description:, example:)
          TypeDefinition.new(
            @name,
            block: merge_blocks(@block, block),
            deprecated: deprecated || @deprecated,
            description: description || @description,
            discriminator: @discriminator,
            example: example || @example,
            kind: @kind,
            scope: @scope,
          )
        end

        private

        def merge_blocks(existing_block, new_block)
          return existing_block unless new_block
          return new_block unless existing_block

          proc do |shape|
            if existing_block.arity.positive?
              existing_block.call(shape)
            else
              shape.instance_eval(&existing_block)
            end
            if new_block.arity.positive?
              new_block.call(shape)
            else
              shape.instance_eval(&new_block)
            end
          end
        end

        def ensure_shape_built!
          return if @shape

          @shape = if object?
                     Object.new
                   else
                     Union.new(discriminator: @discriminator)
                   end

          return unless @block

          @block.arity.positive? ? @block.call(@shape) : @shape.instance_eval(&@block)
        end
      end
    end
  end
end
