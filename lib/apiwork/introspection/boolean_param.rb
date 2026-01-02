# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Boolean param.
    #
    # @example
    #   param.type    # => :boolean
    #   param.scalar? # => true
    class BooleanParam < ScalarParam
    end
  end
end
