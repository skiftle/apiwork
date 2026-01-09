# frozen_string_literal: true

module Apiwork
  module API
    class TypeRegistry
      class TypeDefinition
        attr_reader :definition,
                    :definitions,
                    :description,
                    :example,
                    :format,
                    :name,
                    :payload,
                    :schema_class,
                    :scope

        def initialize(
          name:,
          scope: nil,
          deprecated: false,
          definition: nil,
          definitions: nil,
          description: nil,
          example: nil,
          format: nil,
          payload: nil,
          schema_class: nil
        )
          @name = name
          @scope = scope
          @deprecated = deprecated
          @definition = definition
          @definitions = definitions
          @description = description
          @example = example
          @format = format
          @payload = payload
          @schema_class = schema_class
        end

        def deprecated?
          @deprecated == true
        end

        def all_definitions
          (@definitions || [@definition].compact).presence
        end

        def merge(
          definition:,
          deprecated:,
          description:,
          example:,
          format:,
          schema_class:
        )
          merged_definitions = @definitions&.dup || []
          merged_definitions << @definition if @definition && @definitions.nil?
          merged_definitions << definition if definition

          TypeDefinition.new(
            definition: nil,
            definitions: merged_definitions.compact.presence,
            deprecated: deprecated || @deprecated,
            description: description || @description,
            example: example || @example,
            format: format || @format,
            name: @name,
            payload: @payload,
            schema_class: schema_class || @schema_class,
            scope: @scope,
          )
        end
      end
    end
  end
end
