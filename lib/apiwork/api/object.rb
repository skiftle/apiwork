# frozen_string_literal: true

module Apiwork
  module API
    class Object
      attr_reader :params

      def initialize(
        object: -> { Object.new },
        union: ->(discriminator) { Union.new(discriminator:) }
      )
        @object = object
        @union = union
        @params = {}
      end

      def param(
        name,
        type: nil,
        optional: false,
        as: nil,
        default: nil,
        deprecated: nil,
        description: nil,
        discriminator: nil,
        enum: nil,
        example: nil,
        format: nil,
        internal: nil,
        max: nil,
        min: nil,
        nullable: nil,
        of: nil,
        required: nil,
        value: nil,
        &block
      )
        shape = build_shape(type, discriminator, &block)

        @params[name] = {
          as:,
          default:,
          deprecated:,
          description:,
          discriminator:,
          enum:,
          example:,
          format:,
          internal:,
          max:,
          min:,
          name:,
          nullable:,
          of:,
          optional:,
          required:,
          shape:,
          type:,
          value:,
        }.compact
      end

      private

      def build_shape(type, discriminator, &block)
        return nil unless block

        case type
        when :object
          builder = @object.call
          builder.instance_eval(&block)
          builder
        when :union
          builder = @union.call(discriminator)
          builder.instance_eval(&block)
          builder
        end
      end
    end
  end
end
