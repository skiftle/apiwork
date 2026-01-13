# frozen_string_literal: true

module Apiwork
  module Contract
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
    # @example Variant with enum reference
    #   variant { string enum: :status }
    #
    # @see Contract::Object Block context for object fields
    # @see Contract::Union Block context for union variants
    class Element
      attr_reader :custom_type,
                  :discriminator,
                  :enum,
                  :format,
                  :max,
                  :min,
                  :shape,
                  :type,
                  :value

      # The element type for arrays.
      # @return [Symbol, nil]
      def of_value
        @of
      end

      def initialize(contract_class)
        @contract_class = contract_class
        @custom_type = nil
        @defined = false
        @discriminator = nil
        @enum = nil
        @format = nil
        @max = nil
        @min = nil
        @of = nil
        @shape = nil
        @type = nil
        @value = nil
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
      # @param max [Integer, nil] maximum value or length (strings, integers, decimals, numbers, arrays only)
      # @param min [Integer, nil] minimum value or length (strings, integers, decimals, numbers, arrays only)
      # @param shape [Object, nil] pre-built shape (objects, arrays, unions only)
      # @param value [Object, nil] literal value (literals only)
      # @yield block for defining nested structure (objects, arrays, unions only)
      # @return [void]
      #
      # @example Basic usage
      #   of :string
      #   of :string, enum: %w[a b c]
      #
      # @example With pre-built shape
      #   of :object, shape: prebuilt_shape
      def of(type, discriminator: nil, enum: nil, format: nil, max: nil, min: nil, shape: nil, value: nil, &block)
        resolved_enum = enum.is_a?(Symbol) ? resolve_enum(enum) : enum

        case type
        when :string, :integer, :decimal, :boolean, :number, :datetime, :date, :uuid, :time
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
            builder = Object.new(@contract_class)
            builder.instance_eval(&block)
            @type = :object
            @shape = builder
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
            inner.instance_eval(&block)
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
            builder = Union.new(@contract_class, discriminator:)
            builder.instance_eval(&block)
            @type = :union
            @shape = builder
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

      # @api public
      # Defines a string element.
      #
      # @param enum [Array, Symbol] allowed values or enum reference
      # @param format [String] format hint
      # @param max [Integer] maximum length
      # @param min [Integer] minimum length
      # @return [void]
      def string(enum: nil, format: nil, max: nil, min: nil)
        of(:string, enum:, format:, max:, min:)
      end

      # @api public
      # Defines an integer element.
      #
      # @param enum [Array, Symbol] allowed values or enum reference
      # @param max [Integer] maximum value
      # @param min [Integer] minimum value
      # @return [void]
      def integer(enum: nil, max: nil, min: nil)
        of(:integer, enum:, max:, min:)
      end

      # @api public
      # Defines a decimal element.
      #
      # @param max [Numeric] maximum value
      # @param min [Numeric] minimum value
      # @return [void]
      def decimal(max: nil, min: nil)
        of(:decimal, max:, min:)
      end

      # @api public
      # Defines a boolean element.
      #
      # @return [void]
      def boolean
        of(:boolean)
      end

      # @api public
      # Defines a number element.
      #
      # @param max [Numeric] maximum value
      # @param min [Numeric] minimum value
      # @return [void]
      def number(max: nil, min: nil)
        of(:number, max:, min:)
      end

      # @api public
      # Defines a datetime element.
      #
      # @return [void]
      def datetime
        of(:datetime)
      end

      # @api public
      # Defines a date element.
      #
      # @return [void]
      def date
        of(:date)
      end

      # @api public
      # Defines a UUID element.
      #
      # @return [void]
      def uuid
        of(:uuid)
      end

      # @api public
      # Defines a time element.
      #
      # @return [void]
      def time
        of(:time)
      end

      # @api public
      # Defines a binary element.
      #
      # @return [void]
      def binary
        of(:binary)
      end

      # @api public
      # Defines a literal value element.
      #
      # @param value [Object] the exact value (required)
      # @return [void]
      #
      # @example
      #   literal value: 'card'
      #   literal value: 42
      def literal(value:)
        of(:literal, value:)
      end

      # @api public
      # Defines a reference to a named type.
      #
      # @param type_name [Symbol] type name (also used as default target)
      # @param to [Symbol] explicit target type name
      # @return [void]
      #
      # @example
      #   reference :item
      #   reference :shipping_address, to: :address
      def reference(type_name, to: nil)
        of(to || type_name)
      end

      # @api public
      # Defines an inline object element.
      #
      # @yield block defining object fields
      # @return [void]
      # @see Contract::Object
      #
      # @example
      #   object do
      #     string :name
      #     decimal :amount
      #   end
      def object(&block)
        of(:object, &block)
      end

      # @api public
      # Defines an array element.
      #
      # The block must define exactly one element type.
      #
      # @yield block defining element type
      # @return [void]
      #
      # @example Array of integers
      #   array { integer }
      #
      # @example Array of references
      #   array { reference :item }
      def array(&block)
        of(:array, &block)
      end

      # @api public
      # Defines an inline union element.
      #
      # @param discriminator [Symbol] discriminator field for tagged unions
      # @yield block defining union variants
      # @return [void]
      # @see Contract::Union
      #
      # @example
      #   union do
      #     variant { integer }
      #     variant { string }
      #   end
      def union(discriminator: nil, &block)
        of(:union, discriminator:, &block)
      end

      # The type for `of:` parameter in arrays.
      #
      # @return [Symbol] custom_type if reference, otherwise type
      def of_type
        custom_type || type
      end

      def validate!
        raise ArgumentError, 'must define exactly one type' unless @defined
      end

      private

      def set_type(type_value, enum: nil, format: nil, max: nil, min: nil)
        @type = type_value
        @enum = enum
        @format = format
        @max = max
        @min = min
        @defined = true
      end

      def resolve_enum(enum)
        return nil if enum.nil?
        return enum if enum.is_a?(Array)

        raise ArgumentError, "Enum :#{enum} not found." unless @contract_class.enum?(enum)

        enum
      end
    end
  end
end
