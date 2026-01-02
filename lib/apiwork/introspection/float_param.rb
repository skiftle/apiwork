# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for float types.
    #
    # @example
    #   param.type   # => :float
    #   param.min    # => 0.0
    #   param.max    # => 100.0
    #   param.scalar? # => true
    class FloatParam < ScalarParam
      # @api public
      # @return [Numeric, nil] minimum value
      def min
        @dump[:min]
      end

      # @api public
      # @return [Numeric, nil] maximum value
      def max
        @dump[:max]
      end

      # @api public
      # @return [Hash] structured representation
      def to_h
        result = super
        result[:max] = max
        result[:min] = min
        result
      end
    end
  end
end
