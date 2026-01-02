# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for binary types.
    #
    # @example
    #   param.type    # => :binary
    #   param.binary? # => true
    class BinaryParam < Param
      # @api public
      # @return [Boolean] always true for BinaryParam
      def binary?
        true
      end
    end
  end
end
