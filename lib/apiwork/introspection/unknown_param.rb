# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for unknown types.
    #
    # Used as fallback when the type cannot be determined.
    #
    # @example
    #   param.type     # => :unknown
    #   param.unknown? # => true
    class UnknownParam < Param
      # @api public
      # @return [Boolean] always true for UnknownParam
      def unknown?
        true
      end
    end
  end
end
