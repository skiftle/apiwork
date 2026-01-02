# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Type reference param.
    #
    # The type field contains the symbol name of the referenced type.
    #
    # @example
    #   param.type # => :address (the custom type name)
    class RefTypeParam < Param
    end
  end
end
