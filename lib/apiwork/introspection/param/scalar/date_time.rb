# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Scalar
        # @api public
        # DateTime param.
        #
        # @example
        #   param.type      # => :datetime
        #   param.scalar?   # => true
        #   param.datetime? # => true
        class DateTime < Scalar
          # @api public
          # @return [Boolean] true for datetime params
          def datetime?
            true
          end
        end
      end
    end
  end
end
