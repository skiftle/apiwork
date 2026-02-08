# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Wraps custom type definitions.
    #
    # Types can be objects (with shapes) or unions (with variants).
    #
    # @example Object type
    #   api.types[:address].object?      # => true
    #   api.types[:address].shape[:city] # => Param for city field
    #
    # @example Union type
    #   api.types[:payment_method].union?        # => true
    #   api.types[:payment_method].variants      # => [Param, ...]
    #   api.types[:payment_method].discriminator # => :type
    class Type
      def initialize(dump)
        @dump = dump
      end

      # @api public
      # The type for this type.
      #
      # @return [Symbol, nil]
      def type
        @dump[:type]
      end

      # @api public
      # Whether this type is an object.
      #
      # @return [Boolean]
      def object?
        type == :object
      end

      # @api public
      # Whether this type is a union.
      #
      # @return [Boolean]
      def union?
        type == :union
      end

      # @api public
      # The shape for this type.
      #
      # @return [Hash{Symbol => Param}]
      def shape
        @shape ||= @dump[:shape].transform_values { |dump| Param.build(dump) }
      end

      # @api public
      # The variants for this type.
      #
      # @return [Array<Param>]
      def variants
        @variants ||= @dump[:variants].map { |variant| Param.build(variant) }
      end

      # @api public
      # The discriminator for this type.
      #
      # @return [Symbol, nil]
      def discriminator
        @dump[:discriminator]
      end

      # @api public
      # The description for this type.
      #
      # @return [String, nil]
      def description
        @dump[:description]
      end

      # @api public
      # The extends for this type.
      #
      # @return [Array<Symbol>]
      def extends
        @dump[:extends]
      end

      # @api public
      # Whether this type extends other types.
      #
      # @return [Boolean]
      def extends?
        extends.any?
      end

      # @api public
      # The example for this type.
      #
      # @return [Object, nil]
      def example
        @dump[:example]
      end

      # @api public
      # Whether this type is deprecated.
      #
      # @return [Boolean]
      def deprecated?
        @dump[:deprecated]
      end

      # @api public
      # Converts this type to a hash.
      #
      # @return [Hash]
      def to_h
        {
          deprecated: deprecated?,
          description: description,
          discriminator: discriminator,
          example: example,
          extends: extends,
          shape: shape.transform_values(&:to_h),
          type: type,
          variants: variants.map(&:to_h),
        }
      end
    end
  end
end
