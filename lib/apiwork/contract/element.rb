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

      # Returns the element type for arrays.
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
      # Defines an element type using explicit type parameter.
      #
      # This is the verbose form. Sugar methods like `string`, `integer`
      # are aliases to this method.
      #
      # @param type [Symbol] the type (:string, :integer, :object, :array, etc. or custom type)
      # @param discriminator [Symbol] discriminator field for unions
      # @param enum [Array, Symbol] allowed values or enum reference
      # @param format [String] format hint
      # @param max [Numeric] maximum value/length
      # @param min [Numeric] minimum value/length
      # @param value [Object] literal value (for type: :literal)
      # @yield block for complex types (:object, :array, :union)
      # @return [void]
      #
      # @example Primitive type
      #   string
      #
      # @example Reference to custom type
      #   reference :invoice
      #
      # @example Object with block
      #   object do
      #     string :name
      #   end
      #
      # @example Array with block
      #   array do
      #     string
      #   end
      def of(discriminator: nil, enum: nil, format: nil, max: nil, min: nil, type:, value: nil, &block)
        resolved_enum = enum.is_a?(Symbol) ? resolve_enum(enum) : enum

        case type
        when :string, :integer, :decimal, :boolean, :float, :datetime, :date, :uuid, :time
          set_type(type, format:, max:, min:, enum: resolved_enum)
        when :literal
          @type = :literal
          @value = value
          @defined = true
        when :object
          raise ArgumentError, 'object requires a block' unless block

          builder = Object.new(@contract_class)
          builder.instance_eval(&block)
          @type = :object
          @shape = builder
          @defined = true
        when :array
          raise ArgumentError, 'array requires a block' unless block

          inner = Element.new(@contract_class)
          inner.instance_eval(&block)
          inner.validate!
          @type = :array
          @of = inner.of_type
          @shape = inner.shape
          @defined = true
        when :union
          raise ArgumentError, 'union requires a block' unless block

          builder = Union.new(@contract_class, discriminator:)
          builder.instance_eval(&block)
          @type = :union
          @shape = builder
          @discriminator = discriminator
          @defined = true
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
        of(enum:, format:, max:, min:, type: :string)
      end

      # @api public
      # Defines an integer element.
      #
      # @param enum [Array, Symbol] allowed values or enum reference
      # @param max [Integer] maximum value
      # @param min [Integer] minimum value
      # @return [void]
      def integer(enum: nil, max: nil, min: nil)
        of(enum:, max:, min:, type: :integer)
      end

      # @api public
      # Defines a decimal element.
      #
      # @param max [Numeric] maximum value
      # @param min [Numeric] minimum value
      # @return [void]
      def decimal(max: nil, min: nil)
        of(max:, min:, type: :decimal)
      end

      # @api public
      # Defines a boolean element.
      #
      # @return [void]
      def boolean
        of(type: :boolean)
      end

      # @api public
      # Defines a float element.
      #
      # @param max [Numeric] maximum value
      # @param min [Numeric] minimum value
      # @return [void]
      def float(max: nil, min: nil)
        of(max:, min:, type: :float)
      end

      # @api public
      # Defines a datetime element.
      #
      # @return [void]
      def datetime
        of(type: :datetime)
      end

      # @api public
      # Defines a date element.
      #
      # @return [void]
      def date
        of(type: :date)
      end

      # @api public
      # Defines a UUID element.
      #
      # @return [void]
      def uuid
        of(type: :uuid)
      end

      # @api public
      # Defines a time element.
      #
      # @return [void]
      def time
        of(type: :time)
      end

      # @api public
      # Defines a binary element.
      #
      # @return [void]
      def binary
        of(type: :binary)
      end

      # @api public
      # Defines a JSON element for arbitrary/unstructured JSON data.
      # For structured data with known fields, use object with a block instead.
      #
      # @return [void]
      def json
        of(type: :json)
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
        of(value:, type: :literal)
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
        of(type: to || type_name)
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
        of(type: :object, &block)
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
        of(type: :array, &block)
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
        of(discriminator:, type: :union, &block)
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

      def resolve_enum(enum)
        return nil if enum.nil?
        return enum if enum.is_a?(Array)

        raise ArgumentError, "Enum :#{enum} not found." unless @contract_class.enum?(enum)

        enum
      end
    end
  end
end
