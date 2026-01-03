# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Scalar
        class Numeric
          # @api public
          # Float param.
          #
          # @example
          #   param.type    # => :float
          #   param.min     # => 0.0
          #   param.max     # => 100.0
          #   param.scalar? # => true
          class Float < Numeric
            # @api public
            # @return [Boolean] true for float params
            def float?
              true
            end
          end
        end
      end
    end
  end
end
