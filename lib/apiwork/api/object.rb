# frozen_string_literal: true

module Apiwork
  module API
    # @api public
    # Defines an object shape with named parameters.
    #
    # Objects are the primary way to define structured data in Apiwork.
    # Each object has a set of named parameters with types and constraints.
    #
    # @example Define an address object
    #   object :address do
    #     param :street, type: :string
    #     param :city, type: :string
    #     param :postal_code, type: :string
    #   end
    #
    # @example Inline object in a param
    #   param :shipping, type: :object do
    #     param :street, type: :string
    #     param :city, type: :string
    #   end
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

      # @api public
      # Defines a parameter within this object.
      #
      # @param name [Symbol] parameter name
      # @param type [Symbol] primitive type or reference to named object/union
      # @param optional [Boolean] whether the parameter can be omitted
      # @param as [Symbol] internal name transformation
      # @param default [Object] default value when omitted
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param discriminator [Symbol] discriminator field for inline unions
      # @param enum [Symbol, Array] enum reference or inline values
      # @param example [Object] example value for documentation
      # @param format [String] format hint for documentation
      # @param max [Numeric] maximum value constraint
      # @param min [Numeric] minimum value constraint
      # @param nullable [Boolean] whether the value can be null
      # @param of [Symbol] element type for arrays
      # @param value [Object] literal value constraint
      # @yield optional block for inline object or union definition
      # @return [void]
      #
      # @example Required string parameter
      #   param :title, type: :string
      #
      # @example Optional with default
      #   param :status, type: :string, optional: true, default: 'draft'
      #
      # @example Array of objects
      #   param :items, type: :array, of: :line_item
      #
      # @example Inline object
      #   param :metadata, type: :object do
      #     param :source, type: :string
      #   end
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
