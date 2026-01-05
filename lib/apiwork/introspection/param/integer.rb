# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Integer param representing whole number values.
      #
      # @example Basic usage
      #   param.type       # => :integer
      #   param.scalar?    # => true
      #   param.integer?   # => true
      #   param.numeric?   # => true
      #
      # @example Constraints
      #   param.min          # => 0 or nil
      #   param.max          # => 100 or nil
      #   param.format       # => :int32 or nil
      #   param.boundable?   # => true
      #   param.formattable? # => true
      #
      # @example Enum (scalar-only, use guard)
      #   if param.scalar? && param.enum?
      #     param.enum      # => [1, 2, 3]
      #     param.enum_ref? # => false
      #   end
      #
      # @example Format (scalar-only, use guard)
      #   if param.scalar? && param.formattable?
      #     param.format # => :int32 or nil
      #   end
      class Integer < Base
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
        # @return [Symbol, nil] the format constraint (:int32, :int64)
        def format
          @dump[:format]
        end

        # @api public
        # @return [Boolean] true if this is a scalar type
        def scalar?
          true
        end

        # @api public
        # @return [Boolean] true if this param has enum constraints
        # @see #scalar?
        # @example
        #   if param.scalar? && param.enum?
        #     param.enum # => [1, 2, 3]
        #   end
        def enum?
          @dump[:enum].present?
        end

        # @api public
        # @return [Array, Symbol, nil] enum values (Array) or reference name (Symbol)
        # @see #enum?
        def enum
          @dump[:enum]
        end

        # @api public
        # @return [Boolean] true if enum is a reference to a named enum
        # @see #enum?
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
        # @return [Boolean] true if this param supports format constraints
        # @see #scalar?
        def formattable?
          true
        end

        # @api public
        # @return [Boolean] true if this is an integer param
        def integer?
          true
        end

        # @api public
        # @return [Hash] structured representation
        def to_h
          result = super
          result[:enum] = enum if enum?
          result[:format] = format
          result[:max] = max
          result[:min] = min
          result
        end
      end
    end
  end
end
