# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # JSON param.
    #
    # @example
    #   param.type # => :json
    class JSONParam < Param
      # @api public
      # @return [Boolean] true for JSON params
      def json?
        true
      end
    end
  end
end
