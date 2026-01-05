# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
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
      class Integer < Base
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
