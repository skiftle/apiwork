# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Union param.
    #
    # @example
    #   param.type          # => :union
    #   param.variants      # => [Param, Param, ...]
    #   param.discriminator # => :type (for discriminated unions)
    #   param.union?        # => true
    class UnionParam < Param
      # @api public
      # @return [Array<Param>] variants for unions
      def variants
        @variants ||= (@dump[:variants] || []).map { |dump| Param.build(dump) }
      end

      # @api public
      # @return [Symbol, nil] discriminator field for discriminated unions
      def discriminator
        @dump[:discriminator]
      end

      # @api public
      # @return [Boolean] always true for UnionParam
      def union?
        true
      end

      # @api public
      # @return [Hash] structured representation
      def to_h
        result = super
        result[:discriminator] = discriminator
        result[:variants] = variants.map(&:to_h)
        result
      end
    end
  end
end
