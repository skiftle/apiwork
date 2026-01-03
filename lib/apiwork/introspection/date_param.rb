# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Date param.
    #
    # @example
    #   param.type    # => :date
    #   param.scalar? # => true
    class DateParam < ScalarParam
      # @api public
      # @return [Boolean] true for date params
      def date?
        true
      end
    end
  end
end
