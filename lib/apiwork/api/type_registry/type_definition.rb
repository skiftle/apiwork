# frozen_string_literal: true

module Apiwork
  module API
    class TypeRegistry
      class TypeDefinition
        attr_reader :deprecated,
                    :description,
                    :discriminator,
                    :example,
                    :format,
                    :kind,
                    :name,
                    :schema_class,
                    :scope

        def initialize(
          name,
          kind:,
          scope: nil,
          block: nil,
          deprecated: false,
          description: nil,
          discriminator: nil,
          example: nil,
          format: nil,
          schema_class: nil
        )
          @name = name
          @kind = kind
          @scope = scope
          @block = block
          @deprecated = deprecated
          @description = description
          @discriminator = discriminator
          @example = example
          @format = format
          @schema_class = schema_class
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

        def validate(value, current_depth:, field_path:, max_depth:)
          return nil unless object?

          temp_param = Contract::Object.new(nil)

          params.each do |param_name, param_data|
            add_param_to_definition(temp_param, param_name, param_data)
          end

          temp_param.validate(value, current_depth:, max_depth:, path: field_path)
        end

        def merge(block:, deprecated:, description:, example:, format:)
          TypeDefinition.new(
            @name,
            block: merge_blocks(@block, block),
            deprecated: deprecated || @deprecated,
            description: description || @description,
            discriminator: @discriminator,
            example: example || @example,
            format: format || @format,
            kind: @kind,
            schema_class: @schema_class,
            scope: @scope,
          )
        end

        private

        def merge_blocks(existing_block, new_block)
          return existing_block unless new_block
          return new_block unless existing_block

          proc do
            instance_eval(&existing_block)
            instance_eval(&new_block)
          end
        end

        def add_param_to_definition(target_param, param_name, param_data)
          nested_shape = param_data[:shape]

          if nested_shape.is_a?(Object)
            target_param.param(
              param_name,
              **param_data.except(:name, :shape),
            ) do
              nested_shape.params.each do |nested_name, nested_data|
                param(nested_name, **nested_data.except(:name, :shape))
              end
            end
          elsif nested_shape.is_a?(Union)
            target_param.param(
              param_name,
              **param_data.except(:name, :shape),
            ) do
              nested_shape.variants.each do |variant_data|
                variant_shape = variant_data[:shape]

                if variant_shape.is_a?(Object)
                  variant(**variant_data.except(:shape)) do
                    variant_shape.params.each do |vp_name, vp_data|
                      param(vp_name, **vp_data.except(:name, :shape))
                    end
                  end
                else
                  variant(**variant_data.except(:shape))
                end
              end
            end
          else
            target_param.param(param_name, **param_data.except(:name, :shape))
          end
        end

        def ensure_shape_built!
          return if @shape

          @shape = if object?
                     Object.new
                   else
                     Union.new(discriminator: @discriminator)
                   end

          @shape.instance_eval(&@block) if @block
        end
      end
    end
  end
end
