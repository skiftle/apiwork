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
    class Element
      attr_reader :custom_type,
                  :discriminator,
                  :enum,
                  :format,
                  :max,
                  :min,
                  :of,
                  :shape,
                  :type

      def initialize
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
      end

      # @api public
      # Defines a string element.
      #
      # @param enum [Array] allowed values
      # @param format [String] format hint
      # @param max [Integer] maximum length
      # @param min [Integer] minimum length
      # @return [void]
      def string(enum: nil, format: nil, max: nil, min: nil)
        set_type(:string, enum:, format:, max:, min:)
      end

      # @api public
      # Defines an integer element.
      #
      # @param enum [Array] allowed values
      # @param max [Integer] maximum value
      # @param min [Integer] minimum value
      # @return [void]
      def integer(enum: nil, max: nil, min: nil)
        set_type(:integer, enum:, max:, min:)
      end

      # @api public
      # Defines a decimal element.
      #
      # @param max [Numeric] maximum value
      # @param min [Numeric] minimum value
      # @return [void]
      def decimal(max: nil, min: nil)
        set_type(:decimal, max:, min:)
      end

      # @api public
      # Defines a boolean element.
      #
      # @return [void]
      def boolean
        set_type(:boolean)
      end

      # @api public
      # Defines a float element.
      #
      # @param max [Numeric] maximum value
      # @param min [Numeric] minimum value
      # @return [void]
      def float(max: nil, min: nil)
        set_type(:float, max:, min:)
      end

      # @api public
      # Defines a datetime element.
      #
      # @return [void]
      def datetime
        set_type(:datetime)
      end

      # @api public
      # Defines a date element.
      #
      # @return [void]
      def date
        set_type(:date)
      end

      # @api public
      # Defines a UUID element.
      #
      # @return [void]
      def uuid
        set_type(:uuid)
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
        resolved = to || type_name
        @type = resolved
        @custom_type = resolved
        @defined = true
      end

      # @api public
      # Defines an inline object element.
      #
      # @yield block defining object fields
      # @return [void]
      # @see API::Object
      #
      # @example
      #   object do
      #     string :name
      #     decimal :amount
      #   end
      def object(&block)
        raise ArgumentError, 'object requires a block' unless block

        builder = Object.new
        builder.instance_eval(&block)
        @type = :object
        @shape = builder
        @defined = true
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
        raise ArgumentError, 'array requires a block' unless block

        inner = Element.new
        inner.instance_eval(&block)
        inner.validate!

        @type = :array
        @of = inner.of_type
        @shape = inner.shape
        @defined = true
      end

      # @api public
      # Defines an inline union element.
      #
      # @param discriminator [Symbol] discriminator field for tagged unions
      # @yield block defining union variants
      # @return [void]
      # @see API::Union
      #
      # @example
      #   union do
      #     variant { integer }
      #     variant { string }
      #   end
      def union(discriminator: nil, &block)
        raise ArgumentError, 'union requires a block' unless block

        builder = Union.new(discriminator:)
        builder.instance_eval(&block)
        @type = :union
        @shape = builder
        @discriminator = discriminator
        @defined = true
      end

      # Returns the type for `of:` parameter in arrays.
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
    end
  end
end
