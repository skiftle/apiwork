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
      # @param name [Symbol] field name
      # @param type [Symbol, nil] field type
      # @param as [Symbol, nil] target attribute name
      # @param default [Object, nil] default value
      # @param deprecated [Boolean] (default: false)
      # @param description [String, nil] documentation description
      # @param discriminator [Symbol, nil] discriminator field name (unions only)
      # @param enum [Array, nil] allowed values
      # @param example [Object, nil] example value
      # @param format [Symbol, nil] format hint
      # @param max [Integer, nil] maximum value or length
      # @param min [Integer, nil] minimum value or length
      # @param nullable [Boolean] (default: false)
      # @param of [Symbol, Hash, nil] element type (arrays only)
      # @param optional [Boolean] (default: false)
      # @param required [Boolean] (default: false)
      # @param shape [API::Object, API::Union, nil] pre-built shape
      # @param store [Boolean, nil] whether to persist
      # @param transform [Proc, nil] value transformation lambda
      # @param value [Object, nil] literal value
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
        store: nil,
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
            store:,
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
      # @param name [Symbol] field name
      # @param options [Hash] additional field options
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
      def array(name, **options, &block)
        raise ArgumentError, 'array requires a block' unless block

        element = Element.new
        block.arity.positive? ? yield(element) : element.instance_eval(&block)
        element.validate!

        param(
          name,
          of: {
            enum: element.enum,
            format: element.format,
            max: element.max,
            min: element.min,
            type: element.of_type,
          }.compact,
          shape: element.shape,
          type: :array,
          **options,
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
