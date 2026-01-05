# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Scalar
        # @api public
        # Integer param.
        #
        # @example
        #   param.type         # => :integer
        #   param.min          # => 0 or nil
        #   param.max          # => 100 or nil
        #   param.format       # => :int32 or nil
        #   param.scalar?      # => true
        #   param.numeric?     # => true
        #   param.boundable?   # => true
        #   param.formattable? # => true
        #   param.integer?     # => true
        class Integer < Scalar
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
          # @return [Symbol, nil] format constraint (:int32, :int64)
          def format
            @dump[:format]
          end

          # @api public
          # @return [Boolean] true for numeric params
          def numeric?
            true
          end

          # @api public
          # @return [Boolean] true - integers support min/max constraints
          def boundable?
            true
          end

          # @api public
          # @return [Boolean] true - integers support format constraints (:int32, :int64)
          def formattable?
            true
          end

          # @api public
          # @return [Boolean] true for integer params
          def integer?
            true
          end

          # @api public
          # @return [Hash] structured representation
          def to_h
            result = super
            result[:format] = format
            result[:max] = max
            result[:min] = min
            result
          end
        end
      end
    end
  end
end
