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
    end
  end
end
