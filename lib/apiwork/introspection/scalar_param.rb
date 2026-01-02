# frozen_string_literal: true

module Apiwork
  module Introspection
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
