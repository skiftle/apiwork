# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for time types.
    #
    # @example
    #   param.type    # => :time
    #   param.scalar? # => true
    class TimeParam < ScalarParam
    end
  end
end
