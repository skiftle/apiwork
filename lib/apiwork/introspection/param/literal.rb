# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Literal param representing a constant value.
      #
      # @example Basic usage
      #   param.type     # => :literal
      #   param.literal? # => true
      #   param.scalar?  # => false
      #
      # @example Value
      #   param.value    # => "active" or 42 or true
      class Literal < Base
        # @api public
        # The value for this param.
        #
        # @return [String, Numeric, Boolean, nil]
        def value
          @dump[:value]
        end

        # @api public
        # Whether this param is a literal.
        #
        # @return [Boolean]
        def literal?
          true
        end

        # @api public
        # Converts this param to a hash.
        #
        # @return [Hash]
        def to_h
          result = super
          result[:value] = value
          result
        end
      end
    end
  end
end
