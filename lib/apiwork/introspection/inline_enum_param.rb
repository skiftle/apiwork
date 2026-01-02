# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for inline enum values.
    #
    # @example
    #   param.type         # => :string (base type)
    #   param.enum         # => ["draft", "published", "archived"]
    #   param.inline_enum? # => true
    class InlineEnumParam < Param
      # @api public
      # @return [Array<String>] inline enum values
      def enum
        @dump[:enum]
      end

      # @api public
      # @return [Boolean] always true for InlineEnumParam
      def inline_enum?
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
