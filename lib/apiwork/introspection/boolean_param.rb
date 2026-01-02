# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for boolean types.
    #
    # @example
    #   param.type    # => :boolean
    #   param.scalar? # => true
    class BooleanParam < ScalarParam
    end
  end
end
