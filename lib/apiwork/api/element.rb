# frozen_string_literal: true

module Apiwork
  module API
    # @api public
    # Block context for defining a single type expression.
    #
    # Used inside `array do` and `variant do` blocks where
    # exactly one element type must be defined.
    #
    # @example Array of integers
    #   array :ids do
    #     integer
    #   end
    #
    # @example Array of references
    #   array :items do
    #     reference :item
    #   end
    #
    # @example Variant with options
    #   variant { string enum: %w[pending active] }
    #
    # @see API::Object Block context for object fields
    # @see API::Union Block context for union variants
    class Element < Apiwork::Element
      # @api public
      # Defines the element type.
      #
      # This is the verbose form. Prefer sugar methods (string, integer, etc.)
      # for static definitions. Use `of` for dynamic element generation.
      #
      # @param type [Symbol] element type (:string, :integer, :object, :array, :union, or custom type reference)
      # @param discriminator [Symbol, nil] discriminator field name (unions only)
      # @param enum [Array, nil] allowed values (strings, integers only)
      # @param format [Symbol, nil] format hint (strings only)
      # @param max [Integer, nil] maximum value or length
      # @param min [Integer, nil] minimum value or length
      # @param shape [API::Object, API::Union, nil] pre-built shape
      # @param value [Object, nil] literal value (literals only)
      # @yield block for defining nested structure (instance_eval style)
      # @yieldparam shape [API::Object, API::Union, API::Element]
      # @return [void]
      def of(type, discriminator: nil, enum: nil, format: nil, max: nil, min: nil, shape: nil, value: nil, &block)
        case type
        when :string, :integer, :decimal, :boolean, :number, :datetime, :date, :uuid, :time, :binary
          set_type(type, enum:, format:, max:, min:)
        when :literal
          @type = :literal
          @value = value
          @defined = true
        when :object
          if shape
            @type = :object
            @shape = shape
            @defined = true
          elsif block
            shape = Object.new
            block.arity.positive? ? yield(shape) : shape.instance_eval(&block)
            @type = :object
            @shape = shape
            @defined = true
          else
            raise ArgumentError, 'object requires a block or shape'
          end
        when :array
          if shape
            @type = :array
            @shape = shape
            @defined = true
          elsif block
            inner = Element.new
            block.arity.positive? ? yield(inner) : inner.instance_eval(&block)
            inner.validate!
            @type = :array
            @of = inner.of_type
            @shape = inner.shape
            @defined = true
          else
            raise ArgumentError, 'array requires a block or shape'
          end
        when :union
          if shape
            @type = :union
            @shape = shape
            @discriminator = discriminator
            @defined = true
          elsif block
            shape = Union.new(discriminator:)
            block.arity.positive? ? yield(shape) : shape.instance_eval(&block)
            @type = :union
            @shape = shape
            @discriminator = discriminator
            @defined = true
          else
            raise ArgumentError, 'union requires a block or shape'
          end
        else
          @type = type
          @custom_type = type
          @defined = true
        end
      end
    end
  end
end
