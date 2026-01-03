# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Scalar
        # @api public
        # Boolean param.
        #
        # @example
        #   param.type     # => :boolean
        #   param.scalar?  # => true
        #   param.boolean? # => true
        class Boolean < Scalar
          # @api public
          # @return [Boolean] true for boolean params
          def boolean?
            true
          end
        end
      end
    end
  end
end
