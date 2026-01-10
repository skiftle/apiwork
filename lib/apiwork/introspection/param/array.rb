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
        # @return [Param::Base, nil] the element type for homogeneous arrays
        def of
          @of ||= @dump[:of] ? Param.build(@dump[:of]) : nil
        end

        # @api public
        # @return [Hash{Symbol => Param::Base}] nested field definitions for array-of-objects
        def shape
          return @shape if defined?(@shape)

          @shape = @dump[:shape]&.transform_values { |dump| Param.build(dump) } || {}
        end

        # @api public
        # @return [Integer, nil] the minimum array length
        def min
          @dump[:min]
        end

        # @api public
        # @return [Integer, nil] the maximum array length
        def max
          @dump[:max]
        end

        # @api public
        # @return [Boolean] true if this is an array param
        def array?
          true
        end

        # @api public
        # @return [Boolean] true if this param supports min/max constraints
        def boundable?
          true
        end

        # @api public
        # @return [Hash] structured representation
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
