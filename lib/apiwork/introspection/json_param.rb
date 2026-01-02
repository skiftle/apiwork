# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for json types.
    #
    # @example
    #   param.type  # => :json
    #   param.json? # => true
    class JsonParam < Param
      # @api public
      # @return [Boolean] always true for JsonParam
      def json?
        true
      end
    end
  end
end
