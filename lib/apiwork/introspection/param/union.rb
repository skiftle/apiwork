# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Union param representing a value that can be one of several types.
      #
      # @example Basic usage
      #   param.type      # => :union
      #   param.union?    # => true
      #   param.scalar?   # => false
      #
      # @example Variants
      #   param.variants  # => [Param, Param, ...]
      #
      # @example Discriminated unions
      #   param.discriminator # => :type or nil
      class Union < Base
        # @api public
        # @return [Array<Param::Base>]
        def variants
          @variants ||= @dump[:variants].map { |dump| Param.build(dump) }
        end

        # @api public
        # @return [Symbol, nil]
        def discriminator
          @dump[:discriminator]
        end

        # @api public
        # @return [Boolean]
        def union?
          true
        end

        # @api public
        # Converts this param to a hash.
        #
        # @return [Hash]
        def to_h
          result = super
          result[:discriminator] = discriminator
          result[:variants] = variants.map(&:to_h)
          result
        end
      end
    end
  end
end
