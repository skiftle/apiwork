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
    end
  end
end
