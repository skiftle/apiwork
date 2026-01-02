# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for enum references.
    #
    # @example
    #   param.type      # => :string (base type)
    #   param.enum      # => :status (enum name symbol)
    #   param.enum_ref? # => true
    class EnumRefParam < Param
      # @api public
      # @return [Symbol] enum name reference
      def enum
        @dump[:enum]
      end

      # @api public
      # @return [Boolean] always true for EnumRefParam
      def enum_ref?
        true
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
