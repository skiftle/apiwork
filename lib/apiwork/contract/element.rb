# frozen_string_literal: true

module Apiwork
  module Contract
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
    # @see Contract::Object Block context for object fields
    # @see Contract::Union Block context for union variants
    class Element < Apiwork::Element
      def initialize(contract_class)
        super()
        @contract_class = contract_class
      end

      # @api public
      # Defines the element type.
      #
      # This is the verbose form. Prefer sugar methods (string, integer, etc.)
      # for static definitions. Use `of` for dynamic element generation.
      #
      # @param type [Symbol] element type (:string, :integer, :object, :array, :union, or custom type reference)
      # @param discriminator [Symbol, nil] discriminator field name (unions only)
      # @param enum [Array, Symbol, nil] allowed values or enum reference (strings, integers only)
      # @param format [Symbol, nil] format hint (strings only)
      # @param max [Integer, nil] maximum value or length
      # @param min [Integer, nil] minimum value or length
      # @param shape [Contract::Object, Contract::Union, nil] pre-built shape
      # @param value [Object, nil] literal value (literals only)
      # @yield block for defining nested structure (instance_eval style)
      # @yieldparam shape [Contract::Object, Contract::Union, Contract::Element]
      # @return [void]
      # @raise [ArgumentError] if object, array, or union type is missing block or shape
      #
      # @example instance_eval style
      #   array :tags do
      #     of :object do
      #       string :name
      #       string :color
      #     end
      #   end
      #
      # @example yield style
      #   array :tags do |element|
      #     element.of :object do |object|
      #       object.string :name
      #       object.string :color
      #     end
      #   end
      def of(type, discriminator: nil, enum: nil, format: nil, max: nil, min: nil, shape: nil, value: nil, &block)
        resolved_enum = enum.is_a?(Symbol) ? resolve_enum(enum) : enum

        case type
        when :string, :integer, :decimal, :boolean, :number, :datetime, :date, :uuid, :time, :binary
          set_type(type, format:, max:, min:, enum: resolved_enum)
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
            shape = Object.new(@contract_class)
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
            inner = Element.new(@contract_class)
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
            shape = Union.new(@contract_class, discriminator:)
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

      private

      def resolve_enum(enum)
        return nil if enum.nil?
        return enum if enum.is_a?(Array)

        raise ArgumentError, "Enum :#{enum} not found." unless @contract_class.enum?(enum)

        enum
      end
    end
  end
end
