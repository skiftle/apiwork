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
      # @api public
      # @return [Boolean] true for UUID params
      def uuid?
        true
      end
    end
  end
end
