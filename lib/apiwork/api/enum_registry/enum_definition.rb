# frozen_string_literal: true

module Apiwork
  module API
    class EnumRegistry
      class EnumDefinition
        attr_reader :description,
                    :example,
                    :name,
                    :scope,
                    :values

        def initialize(
          name,
          scope: nil,
          deprecated: false,
          description: nil,
          example: nil,
          values: nil
        )
          @name = name
          @scope = scope
          @deprecated = deprecated
          @description = description
          @example = example
          @values = values
        end

        def deprecated?
          @deprecated == true
        end

        def merge(
          deprecated:,
          description:,
          example:,
          values:
        )
          EnumDefinition.new(
            @name,
            deprecated: deprecated || @deprecated,
            description: description || @description,
            example: example || @example,
            scope: @scope,
            values: values || @values,
          )
        end
      end
    end
  end
end
