# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Scalar
        # @api public
        # UUID param.
        #
        # @example
        #   param.type    # => :uuid
        #   param.scalar? # => true
        class UUID < Scalar
          # @api public
          # @return [Boolean] true for UUID params
          def uuid?
            true
          end
        end
      end
    end
  end
end
