# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for date types.
    #
    # @example
    #   param.type    # => :date
    #   param.scalar? # => true
    class DateParam < ScalarParam
    end
  end
end
