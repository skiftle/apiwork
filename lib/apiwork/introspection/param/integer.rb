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
      # @example Enum
      #   if param.enum?
      #     param.enum      # => [1, 2, 3]
      #     param.enum_ref? # => false
      #   end
      class Integer < Base
        # @api public
        # The minimum value for this param.
        #
        # @return [Numeric, nil]
        def min
          @dump[:min]
        end

        # @api public
        # The maximum value for this param.
        #
        # @return [Numeric, nil]
        def max
          @dump[:max]
        end

        # @api public
        # The format for this param.
        #
        # @return [Symbol, nil]
        def format
          @dump[:format]
        end

        # @api public
        # Whether this param is scalar.
        #
        # @return [Boolean]
        def scalar?
          true
        end

        # @api public
        # Whether this param is an enum.
        #
        # @return [Boolean]
        def enum?
          @dump[:enum].present?
        end

        # @api public
        # The enum values for this param.
        #
        # @return [Array<Integer>, Symbol, nil]
        def enum
          @dump[:enum]
        end

        # @api public
        # Whether this param is an enum reference.
        #
        # @return [Boolean]
        def enum_ref?
          @dump[:enum].is_a?(Symbol)
        end

        # @api public
        # Whether this param is numeric.
        #
        # @return [Boolean]
        def numeric?
          true
        end

        # @api public
        # Whether this param is boundable.
        #
        # @return [Boolean]
        def boundable?
          true
        end

        # @api public
        # Whether this param is formattable.
        #
        # @return [Boolean]
        def formattable?
          true
        end

        # @api public
        # Whether this param is an integer.
        #
        # @return [Boolean]
        def integer?
          true
        end

        # @api public
        # Converts this param to a hash.
        #
        # @return [Hash]
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
