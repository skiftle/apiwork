# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # String param representing text values.
      #
      # @example Basic usage
      #   param.type         # => :string
      #   param.scalar?      # => true
      #   param.string?      # => true
      #
      # @example Constraints
      #   param.min          # => 1 or nil
      #   param.max          # => 255 or nil
      #   param.format       # => :email or nil
      #   param.boundable?   # => true
      #   param.formattable? # => true
      #
      # @example Enum
      #   if param.enum?
      #     param.enum      # => ["draft", "published"]
      #     param.enum_ref? # => false
      #   end
      class String < Base
        # @api public
        # The format for this param.
        #
        # @return [Symbol, nil]
        def format
          @dump[:format]
        end

        # @api public
        # The minimum length for this param.
        #
        # @return [Integer, nil]
        def min
          @dump[:min]
        end

        # @api public
        # The maximum length for this param.
        #
        # @return [Integer, nil]
        def max
          @dump[:max]
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
        # @return [Array<String>, Symbol, nil]
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
        # Whether this param is a string.
        #
        # @return [Boolean]
        def string?
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
