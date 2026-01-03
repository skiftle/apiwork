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

      # @api public
      # @return [Boolean] true for decimal params
      def numeric?
        true
      end

      # @api public
      # @return [Boolean] true - decimals support min/max constraints
      def boundable?
        true
      end

      # @api public
      # @return [Boolean] true for decimal params
      def decimal?
        true
      end
    end
  end
end
