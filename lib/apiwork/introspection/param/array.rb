# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Array param representing ordered collections.
      #
      # @example Basic usage
      #   param.type       # => :array
      #   param.array?     # => true
      #   param.scalar?    # => false
      #
      # @example Element type
      #   param.of         # => Param (element type) or nil
      #   param.shape      # => {} or { field: Param, ... }
      #
      # @example Constraints
      #   param.min        # => 1 or nil
      #   param.max        # => 10 or nil
      #   param.boundable? # => true
      class Array < Base
        # @api public
        # @return [Param::Base, nil]
        def of
          @of ||= @dump[:of] ? Param.build(@dump[:of]) : nil
        end

        # @api public
        # @return [Hash{Symbol => Param::Base}]
        def shape
          return @shape if defined?(@shape)

          @shape = @dump[:shape]&.transform_values { |dump| Param.build(dump) } || {}
        end

        # @api public
        # @return [Integer, nil]
        def min
          @dump[:min]
        end

        # @api public
        # @return [Integer, nil]
        def max
          @dump[:max]
        end

        # @api public
        # @return [Boolean]
        def array?
          true
        end

        # @api public
        # @return [Boolean]
        def boundable?
          true
        end

        # @api public
        # Converts this param to a hash.
        #
        # @return [Hash]
        def to_h
          result = super
          result[:max] = max
          result[:min] = min
          result[:of] = of&.to_h
          result[:shape] = shape.transform_values(&:to_h)
          result
        end
      end
    end
  end
end
