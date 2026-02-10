# frozen_string_literal: true

module Apiwork
  module API
    # @api public
    # Block context for defining reusable object types.
    #
    # Accessed via `object :name do` in API or contract definitions.
    # Use type methods to define fields: {#string}, {#integer}, {#decimal},
    # {#boolean}, {#array}, {#object}, {#union}, {#reference}.
    #
    # @example instance_eval style
    #   object :item do
    #     string :description
    #     decimal :amount
    #   end
    #
    # @example yield style
    #   object :item do |object|
    #     object.string :description
    #     object.decimal :amount
    #   end
    #
    # @see Contract::Object Block context for inline objects
    # @see API::Element Block context for array/variant elements
    class Object < Apiwork::Object
      # @api public
      # Defines a field with explicit type.
      #
      # This is the verbose form. Prefer sugar methods (string, integer, etc.)
      # for static definitions. Use `param` for dynamic field generation.
      #
      # @param name [Symbol]
      #   The field name.
      # @param type [Symbol, nil] (nil)
      #   The field type.
      # @param as [Symbol, nil] (nil)
      #   The target attribute name.
      # @param default [Object, nil] (nil)
      #   The default value.
      # @param deprecated [Boolean] (false)
      #   Whether deprecated. Metadata included in exports.
      # @param description [String, nil] (nil)
      #   The description. Metadata included in exports.
      # @param discriminator [Symbol, nil] (nil)
      #   The discriminator field name. Unions only.
      # @param enum [Array, nil] (nil)
      #   The allowed values.
      # @param example [Object, nil] (nil)
      #   The example value. Metadata included in exports.
      # @param format [Symbol, nil] (nil) [:email, :uri, :uuid]
      #   Format hint for exports. Does not change the type, but exports may add validation or documentation based on it.
      # @param max [Integer, nil] (nil)
      #   The maximum value or length.
      # @param min [Integer, nil] (nil)
      #   The minimum value or length.
      # @param nullable [Boolean] (false)
      #   Whether the value can be `null`.
      # @param of [Symbol, Hash, nil] (nil)
      #   The element type. Arrays only.
      # @param optional [Boolean] (false)
      #   Whether the param is optional.
      # @param required [Boolean] (false)
      #   Whether the param is required.
      # @param shape [API::Object, API::Union, nil] (nil)
      #   The pre-built shape.
      # @param transform [Proc, nil] (nil)
      #   The value transformation lambda.
      # @param value [Object, nil] (nil)
      #   The literal value.
      # @yield block for nested structure
      # @yieldparam shape [API::Object, API::Union, API::Element]
      # @return [void]
      #
      # @example Object with block (instance_eval style)
      #   param :metadata, type: :object do
      #     string :key
      #     string :value
      #   end
      #
      # @example Object with block (yield style)
      #   param :metadata, type: :object do |metadata|
      #     metadata.string :key
      #     metadata.string :value
      #   end
      def param(
        name,
        type: nil,
        as: nil,
        default: nil,
        deprecated: false,
        description: nil,
        discriminator: nil,
        enum: nil,
        example: nil,
        format: nil,
        max: nil,
        min: nil,
        nullable: false,
        of: nil,
        optional: false,
        required: false,
        shape: nil,
        transform: nil,
        value: nil,
        &block
      )
        resolved_of = of
        resolved_shape = shape

        if block && type == :array
          element = Element.new
          block.arity.positive? ? yield(element) : element.instance_eval(&block)
          element.validate!
          resolved_of = element.of_type
          resolved_shape = element.shape
          discriminator = element.discriminator
        else
          resolved_shape ||= build_shape(type, discriminator, &block)
        end

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
            max:,
            min:,
            name:,
            nullable:,
            optional:,
            required:,
            transform:,
            type:,
            value:,
            of: resolved_of,
            shape: resolved_shape,
          }.compact,
        )
      end

      # @api public
      # Defines an array field with element type.
      #
      # @param name [Symbol]
      #   The field name.
      # @param as [Symbol, nil] (nil)
      #   The target attribute name.
      # @param default [Object, nil] (nil)
      #   The default value.
      # @param deprecated [Boolean] (false)
      #   Whether deprecated. Metadata included in exports.
      # @param description [String, nil] (nil)
      #   The description. Metadata included in exports.
      # @param nullable [Boolean] (false)
      #   Whether the value can be `null`.
      # @param optional [Boolean] (false)
      #   Whether the param is optional.
      # @param required [Boolean] (false)
      #   Whether the param is required.
      # @yield block for defining element type
      # @yieldparam element [API::Element]
      # @return [void]
      #
      # @example instance_eval style
      #   array :tags do
      #     string
      #   end
      #
      # @example yield style
      #   array :tags do |element|
      #     element.string
      #   end
      def array(
        name,
        as: nil,
        default: nil,
        deprecated: false,
        description: nil,
        nullable: false,
        optional: false,
        required: false,
        &block
      )
        raise ArgumentError, 'array requires a block' unless block

        element = Element.new
        block.arity.positive? ? yield(element) : element.instance_eval(&block)
        element.validate!

        param(
          name,
          as:,
          default:,
          deprecated:,
          description:,
          nullable:,
          optional:,
          required:,
          of: {
            enum: element.enum,
            format: element.format,
            max: element.max,
            min: element.min,
            type: element.of_type,
          }.compact,
          shape: element.shape,
          type: :array,
        )
      end

      private

      def build_shape(type, discriminator, &block)
        return nil unless block

        case type
        when :object
          shape = Object.new
          block.arity.positive? ? yield(shape) : shape.instance_eval(&block)
          shape
        when :union
          shape = Union.new(discriminator:)
          block.arity.positive? ? yield(shape) : shape.instance_eval(&block)
          shape
        end
      end
    end
  end
end
