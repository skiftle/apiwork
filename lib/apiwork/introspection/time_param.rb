# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Time param.
    #
    # @example
    #   param.type    # => :time
    #   param.scalar? # => true
    class TimeParam < ScalarParam
      # @api public
      # @return [Boolean] true for time params
      def time?
        true
      end
    end
  end
end
