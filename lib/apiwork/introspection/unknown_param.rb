# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Unknown param.
    #
    # Used as fallback when the type cannot be determined.
    #
    # @example
    #   param.type # => :unknown
    class UnknownParam < Param
      # @api public
      # @return [Boolean] true for unknown params
      def unknown?
        true
      end
    end
  end
end
