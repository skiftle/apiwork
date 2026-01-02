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
      # @return [Symbol, nil] type kind (:object or :union)
      def type
        @dump[:type]
      end

      # @api public
      # @return [Boolean] whether this is an object type
      def object?
        type == :object || type.nil?
      end

      # @api public
      # @return [Boolean] whether this is a union type
      def union?
        type == :union
      end

      # @api public
      # @return [Hash{Symbol => Param}] nested fields for object types
      # @see Param
      def shape
        @shape ||= (@dump[:shape] || {}).transform_values { |dump| Param.build(dump) }
      end

      # @api public
      # @return [Array<Param>] variants for union types
      def variants
        @variants ||= (@dump[:variants] || []).map { |variant| Param.build(variant) }
      end

      # @api public
      # @return [Symbol, nil] discriminator field for discriminated unions
      def discriminator
        @dump[:discriminator]
      end

      # @api public
      # @return [String, nil] type description
      def description
        @dump[:description]
      end

      # @api public
      # @return [Object, nil] example value
      def example
        @dump[:example]
      end

      # @api public
      # @return [Boolean] whether this type is deprecated
      def deprecated?
        @dump[:deprecated] == true
      end

      # @api public
      # @return [Hash] structured representation
      def to_h
        {
          deprecated: deprecated?,
          description: description,
          discriminator: discriminator,
          example: example,
          shape: shape.transform_values(&:to_h),
          type: type,
          variants: variants.map(&:to_h),
        }
      end
    end
  end
end
