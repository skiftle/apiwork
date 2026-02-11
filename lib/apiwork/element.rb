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
    # @param enum [Array, Symbol, nil] (nil) allowed values
    # @param format [Symbol, nil] (nil) format hint
    # @param max [Integer, nil] (nil) maximum length
    # @param min [Integer, nil] (nil) minimum length
    # @return [void]
    def string(enum: nil, format: nil, max: nil, min: nil)
      of(:string, enum:, format:, max:, min:)
    end

    # @api public
    # Defines an integer.
    #
    # @param enum [Array, Symbol, nil] (nil) allowed values
    # @param max [Integer, nil] (nil) maximum value
    # @param min [Integer, nil] (nil) minimum value
    # @return [void]
    def integer(enum: nil, max: nil, min: nil)
      of(:integer, enum:, max:, min:)
    end

    # @api public
    # Defines a decimal.
    #
    # @param max [Numeric, nil] (nil) maximum value
    # @param min [Numeric, nil] (nil) minimum value
    # @return [void]
    def decimal(max: nil, min: nil)
      of(:decimal, max:, min:)
    end

    # @api public
    # Defines a number.
    #
    # @param max [Numeric, nil] (nil) maximum value
    # @param min [Numeric, nil] (nil) minimum value
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
    # @yield block defining nested structure
    # @yieldparam object [Object]
    # @return [void]
    #
    # @example instance_eval style
    #   object do
    #     string :name
    #     integer :count
    #   end
    #
    # @example yield style
    #   object do |object|
    #     object.string :name
    #     object.integer :count
    #   end
    def object(&block)
      of(:object, &block)
    end

    # @api public
    # Defines an array.
    #
    # @yield block defining element type
    # @yieldparam element [Element]
    # @return [void]
    #
    # @example instance_eval style
    #   array do
    #     string
    #   end
    #
    # @example yield style
    #   array do |element|
    #     element.string
    #   end
    def array(&block)
      of(:array, &block)
    end

    # @api public
    # Defines a union.
    #
    # @param discriminator [Symbol, nil] (nil) discriminator field name
    # @yield block defining union variants
    # @yieldparam union [Union]
    # @return [void]
    #
    # @example instance_eval style
    #   union discriminator: :type do
    #     variant tag: 'card' do
    #       object do
    #         string :last_four
    #       end
    #     end
    #   end
    #
    # @example yield style
    #   union discriminator: :type do |union|
    #     union.variant tag: 'card' do |variant|
    #       variant.object do |object|
    #         object.string :last_four
    #       end
    #     end
    #   end
    def union(discriminator: nil, &block)
      of(:union, discriminator:, &block)
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
    # @param type_name [Symbol] The type to reference.
    # @return [void]
    def reference(type_name)
      of(type_name)
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
