# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Scalar
        class Numeric < Scalar
          # @api public
          # @return [Numeric, nil] minimum value constraint
          def min
            @dump[:min]
          end

          # @api public
          # @return [Numeric, nil] maximum value constraint
          def max
            @dump[:max]
          end

          # @api public
          # @return [Boolean] true for numeric params
          def numeric?
            true
          end

          # @api public
          # @return [Boolean] true - numeric types support min/max constraints
          def boundable?
            true
          end
        end
      end
    end
  end
end
