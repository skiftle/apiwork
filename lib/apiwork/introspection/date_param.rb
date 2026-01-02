# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for date types.
    #
    # @example
    #   param.type  # => :date
    #   param.date? # => true
    class DateParam < Param
      # @api public
      # @return [Boolean] always true for DateParam
      def date?
        true
      end
    end
  end
end
