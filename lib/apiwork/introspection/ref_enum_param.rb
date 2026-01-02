# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Enum reference param.
    #
    # @example
    #   param.type    # => :string (base type)
    #   param.enum    # => :status (enum name symbol)
    #   param.scalar? # => true
    #   param.enum?   # => true
    #   param.ref?    # => true
    class RefEnumParam < EnumParam
      # @api public
      # @return [Boolean] always true for RefEnumParam
      def ref?
        true
      end
    end
  end
end
