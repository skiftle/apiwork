# frozen_string_literal: true

module Apiwork
  module API
    # @api public
    # Block context for defining a single type expression.
    #
    # Used inside `array do` and `variant do` blocks where
    # exactly one element type must be defined.
    #
    # @example instance_eval style
    #   array :ids do
    #     integer
    #   end
    #
    # @example yield style
    #   array :ids do |element|
    #     element.integer
    #   end
    #
    # @example Array of references
    #   array :items do |element|
    #     element.reference :item
    #   end
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
      # @param discriminator [Symbol, nil] (nil) discriminator field name (unions only)
      # @param enum [Array, nil] (nil) allowed values (strings, integers only)
      # @param format [Symbol, nil] (nil) format hint (strings only)
      # @param max [Integer, nil] (nil) maximum value or length
      # @param min [Integer, nil] (nil) minimum value or length
      # @param value [Object, nil] (nil) literal value (literals only)
      # @yield block for defining nested structure
      # @yieldparam shape [API::Object, API::Union, API::Element]
      # @return [void]
      #
      # @example instance_eval style
      #   array :tags do
      #     of :object do
      #       string :name
      #     end
      #   end
      #
      # @example yield style
      #   array :tags do |element|
      #     element.of :object do |object|
      #       object.string :name
      #     end
      #   end
      def of(type, discriminator: nil, enum: nil, format: nil, max: nil, min: nil, value: nil, &block)
        case type
        when :string, :integer, :decimal, :boolean, :number, :datetime, :date, :uuid, :time, :binary
          set_type(type, enum:, format:, max:, min:)
        when :literal
          @type = :literal
          @value = value
          @defined = true
        when :object
          raise ArgumentError, 'object requires a block' unless block

          shape = Object.new
          block.arity.positive? ? yield(shape) : shape.instance_eval(&block)
          @type = :object
          @shape = shape
          @defined = true
        when :array
          raise ArgumentError, 'array requires a block' unless block

          inner = Element.new
          block.arity.positive? ? yield(inner) : inner.instance_eval(&block)
          inner.validate!
          @type = :array
          @of = inner.of_type
          @shape = inner.shape
          @defined = true
        when :union
          raise ArgumentError, 'union requires a block' unless block

          shape = Union.new(discriminator:)
          block.arity.positive? ? yield(shape) : shape.instance_eval(&block)
          @type = :union
          @shape = shape
          @discriminator = discriminator
          @defined = true
        else
          @type = type
          @custom_type = type
          @defined = true
        end
      end
    end
  end
end
