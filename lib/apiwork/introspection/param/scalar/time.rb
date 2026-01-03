# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Scalar
        # @api public
        # Time param.
        #
        # @example
        #   param.type    # => :time
        #   param.scalar? # => true
        #   param.time?   # => true
        class Time < Scalar
          # @api public
          # @return [Boolean] true for time params
          def time?
            true
          end
        end
      end
    end
  end
end
