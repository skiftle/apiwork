# frozen_string_literal: true

module Apiwork
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
      @value = nil
    end

    # @api public
    # Defines a string.
    #
    # @param enum [Array, Symbol, nil] allowed values
    # @param format [Symbol, nil] format hint
    # @param max [Integer, nil] maximum length
    # @param min [Integer, nil] minimum length
    # @return [void]
    def string(enum: nil, format: nil, max: nil, min: nil)
      of(:string, enum:, format:, max:, min:)
    end

    # @api public
    # Defines an integer.
    #
    # @param enum [Array, Symbol, nil] allowed values
    # @param max [Integer, nil] maximum value
    # @param min [Integer, nil] minimum value
    # @return [void]
    def integer(enum: nil, max: nil, min: nil)
      of(:integer, enum:, max:, min:)
    end

    # @api public
    # Defines a decimal.
    #
    # @param max [Numeric, nil] maximum value
    # @param min [Numeric, nil] minimum value
    # @return [void]
    def decimal(max: nil, min: nil)
      of(:decimal, max:, min:)
    end

    # @api public
    # Defines a number.
    #
    # @param max [Numeric, nil] maximum value
    # @param min [Numeric, nil] minimum value
    # @return [void]
    def number(max: nil, min: nil)
      of(:number, max:, min:)
    end

    # @api public
    # Defines a boolean.
    #
    # @return [void]
    def boolean
      of(:boolean)
    end

    # @api public
    # Defines a datetime.
    #
    # @return [void]
    def datetime
      of(:datetime)
    end

    # @api public
    # Defines a date.
    #
    # @return [void]
    def date
      of(:date)
    end

    # @api public
    # Defines a UUID.
    #
    # @return [void]
    def uuid
      of(:uuid)
    end

    # @api public
    # Defines a time.
    #
    # @return [void]
    def time
      of(:time)
    end

    # @api public
    # Defines a binary.
    #
    # @return [void]
    def binary
      of(:binary)
    end

    # @api public
    # Defines an object.
    #
    # @param shape [Object, nil] pre-built shape
    # @yield block defining nested structure
    # @return [void]
    def object(shape: nil, &block)
      of(:object, shape:, &block)
    end

    # @api public
    # Defines an array.
    #
    # @param shape [Object, nil] pre-built shape
    # @yield block defining element type
    # @return [void]
    def array(shape: nil, &block)
      of(:array, shape:, &block)
    end

    # @api public
    # Defines a union.
    #
    # @param discriminator [Symbol, nil] discriminator field name
    # @param shape [Union, nil] pre-built shape
    # @yield block defining union variants
    # @return [void]
    def union(discriminator: nil, shape: nil, &block)
      of(:union, discriminator:, shape:, &block)
    end

    # @api public
    # Defines a literal value.
    #
    # @param value [Object] the exact value (required)
    # @return [void]
    def literal(value:)
      of(:literal, value:)
    end

    # @api public
    # Defines a reference to a named type.
    #
    # @param type_name [Symbol] type name
    # @param to [Symbol, nil] target type name (defaults to type_name)
    # @return [void]
    def reference(type_name, to: nil)
      of(to || type_name)
    end

    def of_type
      custom_type || type
    end

    def of_value
      @of
    end

    def validate!
      raise ArgumentError, 'must define exactly one type' unless @defined
    end

    def of(type, **options, &block)
      raise NotImplementedError, "#{self.class} must implement #of"
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
