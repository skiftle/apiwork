# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # JSON param.
      #
      # @example
      #   param.type  # => :json
      #   param.json? # => true
      class JSON < Base
        # @api public
        # @return [Boolean] true for JSON params
        def json?
          true
        end
      end
    end
  end
end
