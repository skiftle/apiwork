# frozen_string_literal: true

module Apiwork
  class Object
    TYPES = %i[
      string integer decimal boolean number
      datetime date uuid time binary
    ].freeze

    attr_reader :params

    def initialize
      @params = {}
    end

    # @!method string(name, **options)
    #   @api public
    #   Defines a string field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method string?(name, **options)
    #   @api public
    #   Defines an optional string field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method integer(name, **options)
    #   @api public
    #   Defines an integer field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method integer?(name, **options)
    #   @api public
    #   Defines an optional integer field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method decimal(name, **options)
    #   @api public
    #   Defines a decimal field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method decimal?(name, **options)
    #   @api public
    #   Defines an optional decimal field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method boolean(name, **options)
    #   @api public
    #   Defines a boolean field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method boolean?(name, **options)
    #   @api public
    #   Defines an optional boolean field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method number(name, **options)
    #   @api public
    #   Defines a number field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method number?(name, **options)
    #   @api public
    #   Defines an optional number field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method datetime(name, **options)
    #   @api public
    #   Defines a datetime field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method datetime?(name, **options)
    #   @api public
    #   Defines an optional datetime field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method date(name, **options)
    #   @api public
    #   Defines a date field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method date?(name, **options)
    #   @api public
    #   Defines an optional date field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method uuid(name, **options)
    #   @api public
    #   Defines a UUID field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method uuid?(name, **options)
    #   @api public
    #   Defines an optional UUID field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method time(name, **options)
    #   @api public
    #   Defines a time field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method time?(name, **options)
    #   @api public
    #   Defines an optional time field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method binary(name, **options)
    #   @api public
    #   Defines a binary field.
    #   @param name [Symbol] field name
    #   @return [void]
    #
    # @!method binary?(name, **options)
    #   @api public
    #   Defines an optional binary field.
    #   @param name [Symbol] field name
    #   @return [void]
    TYPES.each do |type_name|
      define_method(type_name) do |name, **options|
        param(name, type: type_name, **options)
      end

      define_method(:"#{type_name}?") do |name, **options|
        param(name, optional: true, type: type_name, **options)
      end
    end

    # @!method object(name, **options, &block)
    #   @api public
    #   Defines an object field.
    #   @param name [Symbol] field name
    #   @yield block defining object fields
    #   @return [void]
    #
    # @!method object?(name, **options, &block)
    #   @api public
    #   Defines an optional object field.
    #   @param name [Symbol] field name
    #   @yield block defining object fields
    #   @return [void]
    def object(name, **options, &block)
      param(name, type: :object, **options, &block)
    end

    def object?(name, **options, &block)
      object(name, optional: true, **options, &block)
    end

    # @!method array(name, **options, &block)
    #   @api public
    #   Defines an array field.
    #   @param name [Symbol] field name
    #   @yield block defining element type
    #   @return [void]
    #
    # @!method array?(name, **options, &block)
    #   @api public
    #   Defines an optional array field.
    #   @param name [Symbol] field name
    #   @yield block defining element type
    #   @return [void]
    def array(name, **options, &block)
      param(name, type: :array, **options, &block)
    end

    def array?(name, **options, &block)
      array(name, optional: true, **options, &block)
    end

    # @!method union(name, **options, &block)
    #   @api public
    #   Defines a union field.
    #   @param name [Symbol] field name
    #   @param discriminator [Symbol] discriminator field for tagged unions
    #   @yield block defining union variants
    #   @return [void]
    #
    # @!method union?(name, **options, &block)
    #   @api public
    #   Defines an optional union field.
    #   @param name [Symbol] field name
    #   @param discriminator [Symbol] discriminator field for tagged unions
    #   @yield block defining union variants
    #   @return [void]
    def union(name, **options, &block)
      param(name, type: :union, **options, &block)
    end

    def union?(name, **options, &block)
      union(name, optional: true, **options, &block)
    end

    def literal(name, value:, **options)
      param(name, value:, type: :literal, **options)
    end

    def reference(name, to: nil, **options)
      param(name, type: to || name, **options)
    end

    def reference?(name, to: nil, **options)
      reference(name, to:, optional: true, **options)
    end

    def param(name, type: nil, **options, &block)
      raise NotImplementedError, "#{self.class} must implement #param"
    end
  end
end
