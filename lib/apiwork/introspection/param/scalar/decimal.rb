# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Scalar
        # @api public
        # Decimal param.
        #
        # @example
        #   param.type       # => :decimal
        #   param.min        # => 0.0 or nil
        #   param.max        # => 100.0 or nil
        #   param.scalar?    # => true
        #   param.numeric?   # => true
        #   param.boundable? # => true
        #   param.decimal?   # => true
        class Decimal < Scalar
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
          # @return [Boolean] true - decimals support min/max constraints
          def boundable?
            true
          end

          # @api public
          # @return [Boolean] true for decimal params
          def decimal?
            true
          end

          # @api public
          # @return [Hash] structured representation
          def to_h
            result = super
            result[:max] = max
            result[:min] = min
            result
          end
        end
      end
    end
  end
end
