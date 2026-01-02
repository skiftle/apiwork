# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Base class for scalar (primitive) parameter types.
    #
    # Scalars are simple value types: string, integer, float, decimal,
    # boolean, datetime, date, time, uuid, binary.
    #
    # @example
    #   param.scalar?  # => true
    #   param.enum?    # => false (unless it's an EnumParam)
    class ScalarParam < Param
      # @api public
      # @return [Boolean] true for all scalar types
      def scalar?
        true
      end

      # @api public
      # @return [Boolean] whether this scalar has enum constraints
      def enum?
        false
      end
    end
  end
end
