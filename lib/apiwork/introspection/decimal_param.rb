# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Decimal param.
    #
    # @example
    #   param.type    # => :decimal
    #   param.min     # => 0.0
    #   param.max     # => 100.0
    #   param.scalar? # => true
    class DecimalParam < ScalarParam
      # @api public
      # @return [BigDecimal, nil] minimum value constraint
      def min
        @dump[:min]
      end

      # @api public
      # @return [BigDecimal, nil] maximum value constraint
      def max
        @dump[:max]
      end
    end
  end
end
