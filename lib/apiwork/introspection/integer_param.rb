# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for integer types.
    #
    # @example
    #   param.type     # => :integer
    #   param.min      # => 0
    #   param.max      # => 100
    #   param.format   # => :int32, :int64
    #   param.integer? # => true
    class IntegerParam < Param
      # @api public
      # @return [Symbol, nil] format hint (:int32, :int64)
      def format
        @dump[:format]
      end

      # @api public
      # @return [Integer, nil] minimum value
      def min
        @dump[:min]
      end

      # @api public
      # @return [Integer, nil] maximum value
      def max
        @dump[:max]
      end

      # @api public
      # @return [Boolean] always true for IntegerParam
      def integer?
        true
      end

      # @api public
      # @return [Hash] structured representation
      def to_h
        result = super
        result[:format] = format
        result[:max] = max
        result[:min] = min
        result
      end
    end
  end
end
