# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Literal param.
    #
    # @example
    #   param.type     # => :literal
    #   param.value    # => "active" or 42 or true
    #   param.literal? # => true
    class LiteralParam < Param
      # @api public
      # @return [Object, nil] literal value
      def value
        @dump[:value]
      end

      # @api public
      # @return [Boolean] always true for LiteralParam
      def literal?
        true
      end

      # @api public
      # @return [Hash] structured representation
      def to_h
        result = super
        result[:value] = value
        result
      end
    end
  end
end
