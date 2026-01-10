# frozen_string_literal: true

module Apiwork
  module API
    # @api public
    # Block context for defining reusable object types.
    #
    # Accessed via `object :name do` in API or contract definitions.
    # Use {#param} to define fields.
    #
    # @example Define a reusable type
    #   object :item do
    #     param :description, type: :string
    #     param :amount, type: :decimal
    #   end
    #
    # @example Reference in contract
    #   param :items, type: :array, of: :item
    #
    # @see Contract::Object Block context for inline objects
    class Object
      attr_reader :params

      def initialize
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
      # @return [void]
      # @see API::Object
      # @see API::Union
      #
      # @example Basic param
      #   param :amount, type: :decimal
      #
      # @example Inline object
      #   param :customer, type: :object do
      #     param :name, type: :string
      #   end
      #
      # @example Inline union
      #   param :payment_method, type: :union, discriminator: :type do
      #     variant tag: 'card', type: :object do
      #       param :last_four, type: :string
      #     end
      #     variant tag: 'bank', type: :object do
      #       param :account_number, type: :string
      #     end
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

        @params[name] = (@params[name] || {}).merge(
          {
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
          }.compact,
        )
      end

      private

      def build_shape(type, discriminator, &block)
        return nil unless block

        case type
        when :object
          builder = Object.new
          builder.instance_eval(&block)
          builder
        when :union
          builder = Union.new(discriminator:)
          builder.instance_eval(&block)
          builder
        end
      end
    end
  end
end
