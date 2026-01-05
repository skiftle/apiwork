# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # JSON param representing arbitrary JSON data.
      #
      # Use this for untyped or dynamic data structures.
      #
      # @example Basic usage
      #   param.type    # => :json
      #   param.json?   # => true
      #   param.scalar? # => false
      class JSON < Base
        # @api public
        # @return [Boolean] true if this is a JSON param
        def json?
          true
        end
      end
    end
  end
end
