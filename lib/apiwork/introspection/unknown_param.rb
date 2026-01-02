# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for unknown types.
    #
    # Used as fallback when the type cannot be determined.
    #
    # @example
    #   param.type # => :unknown
    class UnknownParam < Param
    end
  end
end
