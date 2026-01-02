# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for binary types.
    #
    # @example
    #   param.type    # => :binary
    #   param.scalar? # => true
    class BinaryParam < ScalarParam
    end
  end
end
