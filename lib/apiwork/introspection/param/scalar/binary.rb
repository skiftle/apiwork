# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Scalar
        # @api public
        # Binary param.
        #
        # @example
        #   param.type    # => :binary
        #   param.scalar? # => true
        #   param.binary? # => true
        class Binary < Scalar
          # @api public
          # @return [Boolean] true for binary params
          def binary?
            true
          end
        end
      end
    end
  end
end
