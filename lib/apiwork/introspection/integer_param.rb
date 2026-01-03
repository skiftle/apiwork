# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Integer param.
    #
    # @example
    #   param.type    # => :integer
    #   param.min     # => 0
    #   param.max     # => 100
    #   param.format  # => :int32, :int64
    #   param.scalar? # => true
    class IntegerParam < ScalarParam
      # @api public
      # @return [Symbol, nil] format constraint (:int32, :int64)
      def format
        @dump[:format]
      end

      # @api public
      # @return [Integer, nil] minimum value constraint
      def min
        @dump[:min]
      end

      # @api public
      # @return [Integer, nil] maximum value constraint
      def max
        @dump[:max]
      end

      # @api public
      # @return [Boolean] true for integer params
      def numeric?
        true
      end
    end
  end
end
