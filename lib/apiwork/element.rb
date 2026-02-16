# frozen_string_literal: true

module Apiwork
  class Element
    # @api public
    # @return [Symbol, nil] the discriminator field name for unions
    attr_reader :discriminator

    # @api public
    # @return [Element, nil] the inner element type for nested arrays
    attr_reader :inner

    # @api public
    # @return [Object, nil] the nested shape for objects
    attr_reader :shape

    # @api public
    # @return [Symbol, nil] the element type
    attr_reader :type

    attr_reader :custom_type,
                :enum,
                :format,
                :max,
                :min,
                :value

    def initialize
      @custom_type = nil
      @defined = false
      @discriminator = nil
      @enum = nil
      @format = nil
      @inner = nil
      @max = nil
      @min = nil
      @shape = nil
      @type = nil
      @value = nil
    end

    # @api public
    # Defines a string.
    #
    # @param enum [Array, Symbol, nil] (nil)
    #   The allowed values.
    # @param format [Symbol, nil] (nil) [:date, :datetime, :email, :hostname, :ipv4, :ipv6, :password, :url, :uuid]
    #   Format hint for exports. Does not change the type, but exports may add validation or documentation based on it.
    #   Valid formats by type: `:string`.
    # @param max [Integer, nil] (nil)
    #   The maximum length.
    # @param min [Integer, nil] (nil)
    #   The minimum length.
    # @return [void]
    #
    # @example Basic string
    #   array :tags do
    #     string
    #   end
    #
    # @example With length constraints
    #   array :tags do
    #     string min: 1, max: 50
    #   end
    def string(enum: nil, format: nil, max: nil, min: nil)
      of(:string, enum:, format:, max:, min:)
    end

    # @api public
    # Defines an integer.
    #
    # @param enum [Array, Symbol, nil] (nil)
    #   The allowed values.
    # @param max [Integer, nil] (nil)
    #   The maximum value.
    # @param min [Integer, nil] (nil)
    #   The minimum value.
    # @return [void]
    #
    # @example Basic integer
    #   array :counts do
    #     integer
    #   end
    #
    # @example With range constraints
    #   array :scores do
    #     integer min: 0, max: 100
    #   end
    def integer(enum: nil, max: nil, min: nil)
      of(:integer, enum:, max:, min:)
    end

    # @api public
    # Defines a decimal.
    #
    # @param max [Numeric, nil] (nil)
    #   The maximum value.
    # @param min [Numeric, nil] (nil)
    #   The minimum value.
    # @return [void]
    #
    # @example Basic decimal
    #   array :amounts do
    #     decimal
    #   end
    #
    # @example With range constraints
    #   array :prices do
    #     decimal min: 0
    #   end
    def decimal(max: nil, min: nil)
      of(:decimal, max:, min:)
    end

    # @api public
    # Defines a number.
    #
    # @param max [Numeric, nil] (nil)
    #   The maximum value.
    # @param min [Numeric, nil] (nil)
    #   The minimum value.
    # @return [void]
    #
    # @example Basic number
    #   array :coordinates do
    #     number
    #   end
    #
    # @example With range constraints
    #   array :latitudes do
    #     number min: -90, max: 90
    #   end
    def number(max: nil, min: nil)
      of(:number, max:, min:)
    end

    # @api public
    # Defines a boolean.
    #
    # @return [void]
    #
    # @example
    #   array :flags do
    #     boolean
    #   end
    def boolean
      of(:boolean)
    end

    # @api public
    # Defines a datetime.
    #
    # @return [void]
    #
    # @example
    #   array :timestamps do
    #     datetime
    #   end
    def datetime
      of(:datetime)
    end

    # @api public
    # Defines a date.
    #
    # @return [void]
    #
    # @example
    #   array :dates do
    #     date
    #   end
    def date
      of(:date)
    end

    # @api public
    # Defines a UUID.
    #
    # @return [void]
    #
    # @example
    #   array :ids do
    #     uuid
    #   end
    def uuid
      of(:uuid)
    end

    # @api public
    # Defines a time.
    #
    # @return [void]
    #
    # @example
    #   array :times do
    #     time
    #   end
    def time
      of(:time)
    end

    # @api public
    # Defines a binary.
    #
    # @return [void]
    #
    # @example
    #   array :blobs do
    #     binary
    #   end
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
    #   array :items do
    #     object do
    #       string :name
    #       decimal :price
    #     end
    #   end
    #
    # @example yield style
    #   array :items do |element|
    #     element.object do |object|
    #       object.string :name
    #       object.decimal :price
    #     end
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
    #   array :matrix do
    #     array do
    #       integer
    #     end
    #   end
    #
    # @example yield style
    #   array :matrix do |element|
    #     element.array do |inner|
    #       inner.integer
    #     end
    #   end
    def array(&block)
      of(:array, &block)
    end

    # @api public
    # Defines a union.
    #
    # @param discriminator [Symbol, nil] (nil)
    #   The discriminator field name.
    # @yield block defining union variants
    # @yieldparam union [Union]
    # @return [void]
    #
    # @example instance_eval style
    #   array :payments do
    #     union discriminator: :type do
    #       variant tag: 'card' do
    #         object do
    #           string :last_four
    #         end
    #       end
    #     end
    #   end
    #
    # @example yield style
    #   array :payments do |element|
    #     element.union discriminator: :type do |union|
    #       union.variant tag: 'card' do |variant|
    #         variant.object do |object|
    #           object.string :last_four
    #         end
    #       end
    #     end
    #   end
    def union(discriminator: nil, &block)
      of(:union, discriminator:, &block)
    end

    # @api public
    # Defines a literal value.
    #
    # @param value [Object]
    #   The literal value.
    # @return [void]
    #
    # @example
    #   variant tag: 'card' do
    #     literal value: 'card'
    #   end
    def literal(value:)
      of(:literal, value:)
    end

    # @api public
    # Defines a reference to a named type.
    #
    # @param type_name [Symbol]
    #   The type to reference.
    # @return [void]
    #
    # @example
    #   array :items do
    #     reference :item
    #   end
    def reference(type_name)
      of(type_name)
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
