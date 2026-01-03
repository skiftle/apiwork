# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Float param.
    #
    # @example
    #   param.type    # => :float
    #   param.min     # => 0.0
    #   param.max     # => 100.0
    #   param.scalar? # => true
    class FloatParam < ScalarParam
      # @api public
      # @return [Float, nil] minimum value constraint
      def min
        @dump[:min]
      end

      # @api public
      # @return [Float, nil] maximum value constraint
      def max
        @dump[:max]
      end

      # @api public
      # @return [Boolean] true for float params
      def numeric?
        true
      end
    end
  end
end
