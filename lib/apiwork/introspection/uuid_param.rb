# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # UUID param.
    #
    # @example
    #   param.type    # => :uuid
    #   param.scalar? # => true
    class UUIDParam < ScalarParam
    end
  end
end
