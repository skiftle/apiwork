# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for time types.
    #
    # @example
    #   param.type  # => :time
    #   param.time? # => true
    class TimeParam < Param
      # @api public
      # @return [Boolean] always true for TimeParam
      def time?
        true
      end
    end
  end
end
