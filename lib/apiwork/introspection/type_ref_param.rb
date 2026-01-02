# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for custom type references.
    #
    # The type field contains the symbol name of the referenced type.
    #
    # @example
    #   param.type      # => :address (the custom type name)
    #   param.type_ref? # => true
    class TypeRefParam < Param
      # @api public
      # @return [Boolean] always true for TypeRefParam
      def type_ref?
        true
      end
    end
  end
end
