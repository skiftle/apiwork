# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Base class for enum params.
    #
    # Enum params are scalar types with constrained values.
    # Subclasses: RefEnumParam (references named enum), InlineEnumParam (inline values).
    #
    # @example
    #   param.scalar?  # => true (inherited from ScalarParam)
    #   param.enum?    # => true
    #   param.ref?     # => true/false depending on subclass
    #   param.inline?  # => true/false depending on subclass
    class EnumParam < ScalarParam
      # @api public
      # @return [Boolean] true for all enum types
      def enum?
        true
      end

      # @api public
      # @return [Boolean] whether this is a reference to a named enum
      def ref?
        false
      end

      # @api public
      # @return [Boolean] whether this has inline enum values
      def inline?
        false
      end

      # @api public
      # @return [Symbol, Array] enum reference or inline values
      def enum
        @dump[:enum]
      end

      # @api public
      # @return [Hash] structured representation
      def to_h
        result = super
        result[:enum] = enum
        result
      end
    end
  end
end
