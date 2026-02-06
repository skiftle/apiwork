# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Number param representing floating-point number values.
      #
      # @example Basic usage
      #   param.type       # => :number
      #   param.scalar?    # => true
      #   param.number?    # => true
      #   param.numeric?   # => true
      #
      # @example Constraints
      #   param.min          # => 0.0 or nil
      #   param.max          # => 100.0 or nil
      #   param.boundable?   # => true
      #   param.formattable? # => false
      #
      # @example Enum
      #   if param.enum?
      #     param.enum      # => [0.5, 1.0, 1.5]
      #     param.enum_ref? # => false
      #   end
      class Number < Base
        # @api public
        # @return [Numeric, nil] the minimum value constraint
        def min
          @dump[:min]
        end

        # @api public
        # @return [Numeric, nil] the maximum value constraint
        def max
          @dump[:max]
        end

        # @api public
        # @return [Boolean] true if this is a scalar type
        def scalar?
          true
        end

        # @api public
        # @return [Boolean] true if this param has enum constraints
        def enum?
          @dump[:enum].present?
        end

        # @api public
        # @return [Array<Numeric>, Symbol, nil] enum values (Array) or reference name (Symbol)
        # @see #enum?
        def enum
          @dump[:enum]
        end

        # @api public
        # @return [Boolean] true if enum is a reference to a named enum
        def enum_ref?
          @dump[:enum].is_a?(Symbol)
        end

        # @api public
        # @return [Boolean] true if this is a numeric param
        def numeric?
          true
        end

        # @api public
        # @return [Boolean] true if this param supports min/max constraints
        def boundable?
          true
        end

        # @api public
        # @return [Boolean] true if this is a number param
        def number?
          true
        end

        # @api public
        # @return [Boolean] false — numbers do not support format constraints
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
