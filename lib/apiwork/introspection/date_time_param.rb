# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # DateTime param.
    #
    # @example
    #   param.type    # => :datetime
    #   param.scalar? # => true
    class DateTimeParam < ScalarParam
      # @api public
      # @return [Boolean] true for datetime params
      def datetime?
        true
      end
    end
  end
end
