# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Inline enum param.
    #
    # @example
    #   param.type    # => :string (base type)
    #   param.enum    # => ["draft", "published", "archived"]
    #   param.scalar? # => true
    #   param.enum?   # => true
    #   param.inline? # => true
    class InlineEnumParam < EnumParam
      # @api public
      # @return [Boolean] always true for InlineEnumParam
      def inline?
        true
      end
    end
  end
end
