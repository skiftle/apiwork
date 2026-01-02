# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for uuid types.
    #
    # @example
    #   param.type    # => :uuid
    #   param.scalar? # => true
    class UuidParam < ScalarParam
    end
  end
end
