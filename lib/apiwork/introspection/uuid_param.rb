# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for uuid types.
    #
    # @example
    #   param.type  # => :uuid
    #   param.uuid? # => true
    class UuidParam < Param
      # @api public
      # @return [Boolean] always true for UuidParam
      def uuid?
        true
      end
    end
  end
end
