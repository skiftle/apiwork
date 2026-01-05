# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Float param.
      #
      # @example
      #   param.type       # => :float
      #   param.min        # => 0.0 or nil
      #   param.max        # => 100.0 or nil
      #   param.scalar?    # => true
      #   param.numeric?   # => true
      #   param.boundable? # => true
      #   param.float?     # => true
      class Float < Base
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
        # @return [Boolean] true for all scalar types
        def scalar?
          true
        end

        # @api public
        # @return [Boolean] whether this scalar has enum constraints
        def enum?
          @dump[:enum].present?
        end

        # @api public
        # @return [Array, Symbol, nil] inline values (Array) or ref name (Symbol)
        def enum
          @dump[:enum]
        end

        # @api public
        # @return [Boolean] whether this is a reference to a named enum
        def enum_ref?
          @dump[:enum].is_a?(Symbol)
        end

        # @api public
        # @return [Boolean] true for numeric params
        def numeric?
          true
        end

        # @api public
        # @return [Boolean] true - floats support min/max constraints
        def boundable?
          true
        end

        # @api public
        # @return [Boolean] true for float params
        def float?
          true
        end

        # @api public
        # @return [Boolean] false - floats do not support format constraints
        def formattable?
          false
        end

        # @api public
        # @return [Hash] structured representation
        def to_h
          result = super
          result[:enum] = enum if enum?
          result[:max] = max
          result[:min] = min
          result
        end
      end
    end
  end
end
