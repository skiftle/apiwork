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
    end
  end
end
