# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for boolean types.
    #
    # @example
    #   param.type     # => :boolean
    #   param.boolean? # => true
    class BooleanParam < Param
      # @api public
      # @return [Boolean] always true for BooleanParam
      def boolean?
        true
      end
    end
  end
end
