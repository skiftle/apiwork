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
      # @return [Symbol, nil]
      def type
        @dump[:type]
      end

      # @api public
      # @return [Boolean]
      def object?
        type == :object
      end

      # @api public
      # @return [Boolean]
      def union?
        type == :union
      end

      # @api public
      # @return [Hash{Symbol => Param}]
      # @see Param
      def shape
        @shape ||= @dump[:shape].transform_values { |dump| Param.build(dump) }
      end

      # @api public
      # @return [Array<Param>]
      def variants
        @variants ||= @dump[:variants].map { |variant| Param.build(variant) }
      end

      # @api public
      # @return [Symbol, nil]
      def discriminator
        @dump[:discriminator]
      end

      # @api public
      # @return [String, nil]
      def description
        @dump[:description]
      end

      # @api public
      # @return [Array<Symbol>]
      def extends
        @dump[:extends]
      end

      # @api public
      # @return [Boolean]
      def extends?
        extends.any?
      end

      # @api public
      # @return [Object, nil]
      def example
        @dump[:example]
      end

      # @api public
      # @return [Boolean]
      def deprecated?
        @dump[:deprecated]
      end

      # @api public
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
