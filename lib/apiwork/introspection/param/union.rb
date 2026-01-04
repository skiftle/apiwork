# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Union param.
      #
      # @example
      #   param.type          # => :union
      #   param.variants      # => [Param, ...]
      #   param.discriminator # => :type or nil
      #   param.union?        # => true
      class Union < Base
        # @api public
        # @return [Array<Param::Base>] variants for unions
        def variants
          @variants ||= @dump[:variants].map { |dump| Param.build(dump) }
        end

        # @api public
        # @return [Symbol, nil] discriminator field for discriminated unions
        def discriminator
          @dump[:discriminator]
        end

        # @api public
        # @return [Boolean] always true for Union
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
end
