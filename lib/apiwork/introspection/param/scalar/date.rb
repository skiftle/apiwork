# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Scalar
        # @api public
        # Date param.
        #
        # @example
        #   param.type    # => :date
        #   param.scalar? # => true
        class Date < Scalar
          # @api public
          # @return [Boolean] true for date params
          def date?
            true
          end
        end
      end
    end
  end
end
