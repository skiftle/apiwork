# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Scalar
        class Numeric
          # @api public
          # Decimal param.
          #
          # @example
          #   param.type       # => :decimal
          #   param.min        # => 0.0
          #   param.max        # => 100.0
          #   param.scalar?    # => true
          #   param.numeric?   # => true
          #   param.boundable? # => true
          #   param.decimal?   # => true
          class Decimal < Numeric
            # @api public
            # @return [Boolean] true for decimal params
            def decimal?
              true
            end
          end
        end
      end
    end
  end
end
