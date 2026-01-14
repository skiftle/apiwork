# frozen_string_literal: true

module Apiwork
  class Element
    TYPES = %i[
      string integer decimal boolean number
      datetime date uuid time binary
      object array union
    ].freeze

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

    # @!method string(**options, &block)
    #   @api public
    #   Defines a string element.
    #   @return [void]
    #
    # @!method integer(**options, &block)
    #   @api public
    #   Defines an integer element.
    #   @return [void]
    #
    # @!method decimal(**options, &block)
    #   @api public
    #   Defines a decimal element.
    #   @return [void]
    #
    # @!method boolean(**options, &block)
    #   @api public
    #   Defines a boolean element.
    #   @return [void]
    #
    # @!method number(**options, &block)
    #   @api public
    #   Defines a number element.
    #   @return [void]
    #
    # @!method datetime(**options, &block)
    #   @api public
    #   Defines a datetime element.
    #   @return [void]
    #
    # @!method date(**options, &block)
    #   @api public
    #   Defines a date element.
    #   @return [void]
    #
    # @!method uuid(**options, &block)
    #   @api public
    #   Defines a UUID element.
    #   @return [void]
    #
    # @!method time(**options, &block)
    #   @api public
    #   Defines a time element.
    #   @return [void]
    #
    # @!method binary(**options, &block)
    #   @api public
    #   Defines a binary element.
    #   @return [void]
    #
    # @!method object(**options, &block)
    #   @api public
    #   Defines an object element.
    #   @return [void]
    #
    # @!method array(**options, &block)
    #   @api public
    #   Defines an array element.
    #   @return [void]
    #
    # @!method union(**options, &block)
    #   @api public
    #   Defines a union element.
    #   @return [void]
    TYPES.each do |type_name|
      define_method(type_name) do |**options, &block|
        of(type_name, **options, &block)
      end
    end

    def literal(value:)
      of(:literal, value:)
    end

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
